import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Himnario/helpers/isAndroid.dart';
import 'package:Himnario/helpers/smallDevice.dart';
import 'package:Himnario/models/himnos.dart';
import 'package:Himnario/models/tema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import './components/bodyHimno.dart';
import 'components/botonVoz.dart';
import './components/slider.dart';

import 'package:Himnario/api/api.dart';

class HimnoPage extends StatefulWidget {
  final int numero;
  final String titulo;

  HimnoPage({
    required this.numero,
    required this.titulo,
  });

  @override
  _HimnoPageState createState() => _HimnoPageState();
}

class _HimnoPageState extends State<HimnoPage> with SingleTickerProviderStateMixin {
  late AnimationController switchModeController;
  late StreamSubscription positionSubscription;
  late StreamSubscription completeSubscription;
  late PhotoViewScaleStateController scaleController;

  late int totalDuration;

  List<AudioPlayer> audioVoces = [new AudioPlayer(), new AudioPlayer(), new AudioPlayer(), new AudioPlayer(), new AudioPlayer()];
  List<String> stringVoces = ['Soprano', 'Tenor', 'ContraAlto', 'Bajo', 'Todos'];
  int currentVoice = 4;
  bool modoVoces = false;
  bool start = false;
  bool vozDisponible = false;
  bool cargando = true;
  bool descargado = false;
  int max = 0;
  int doneCount = 0;
  double currentProgress = 0.0;
  Duration currentDuration = Duration();
  HttpClient? cliente = HttpClient();

  // Lyrics Variables
  bool favorito = false;
  List<Parrafo> estrofas = [];
  List<File?> archivos = [null, null, null, null, null];
  bool acordes = false;
  double initFontSizePortrait = 16.0;
  double initFontSizeLandscape = 16.0;
  late Database db;
  String tema = '';
  String subTema = '';
  int temaId = 1;

  SharedPreferences? prefs;

  // Sheet variables
  bool sheet = false;
  bool sheetReady = false;
  bool sheetAvailable = false;
  File sheetFile = File('/a.jpg');
  PhotoViewController sheetController = PhotoViewController();
  Orientation? currentOrientation;

  @override
  void initState() {
    WakelockPlus.enable();

    switchModeController = AnimationController(duration: Duration(milliseconds: 200), vsync: this)
      ..addListener(() {
        setState(() {});
      });

    scaleController = PhotoViewScaleStateController()
      ..addIgnorableListener(() {
        if (scaleController.scaleState == PhotoViewScaleState.covering) {
          scaleController.scaleState = PhotoViewScaleState.originalSize;
        }
      });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light));
    getHimno();

    super.initState();
  }

  Future<Database> initDB() async {
    String databasesPath = (await getApplicationDocumentsDirectory()).path;
    String path = databasesPath + "/himnos.db";
    db = await openDatabase(path);
    return db;
  }

  void deleteVocesFiles() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    for (int i = 0; i < audioVoces.length; ++i) {
      try {
        File aux = File(path + '/${widget.numero}-${stringVoces[i]}.mp3');
        if (aux.existsSync()) aux.delete();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<Null> initVocesDownloaded() async {
    setState(() {
      cargando = true;
      vozDisponible = true;
    });

    String path = (await getApplicationDocumentsDirectory()).path;
    if (cliente != null && mounted)
      for (int i = 0; i < audioVoces.length; ++i) {
        bool success = false;

        if (File(path + '/${widget.numero}-${stringVoces[i]}.mp3').existsSync()) {
          try {
            await audioVoces[i].setSourceDeviceFile(path + '/${widget.numero}-${stringVoces[i]}.mp3');
            success = true;
          } catch (e) {
            success = false;
          }
        }

        while (!success) {
          http.Response res = await http.get(Uri.parse(VoicesApi.voiceAvailable(widget.numero)));
          if (res.statusCode == 404) {
            return null;
          }
          HttpClient cliente = HttpClient();
          HttpClientRequest request = await cliente.getUrl(Uri.parse(VoicesApi.getVoice(widget.numero, stringVoces[i])));
          HttpClientResponse response = await request.close();
          Uint8List bytes = await consolidateHttpClientResponseBytes(response);
          File archivo = File(path + '/${widget.numero}-${stringVoces[i]}.mp3');
          await archivo.writeAsBytes(bytes);

          try {
            await audioVoces[i].setSourceDeviceFile(path + '/${widget.numero}-${stringVoces[i]}.mp3');
            success = true;
          } catch (e) {
            success = false;
          }
        }
        await audioVoces[i].setReleaseMode(ReleaseMode.stop);
      }
    positionSubscription = audioVoces[4].onPositionChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          currentProgress = duration.inMilliseconds / totalDuration;
          currentDuration = duration;
        });
      }
    });
    completeSubscription = audioVoces[4].onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          start = false;
          currentProgress = 0.0;
        });
      }
    });

    if (cliente != null && mounted) {
      setState(() => cargando = false);
    } else if (archivos[0] == null && !descargado) deleteVocesFiles();
    return null;
  }

  Future<Null> checkPartitura(String path) async {
    File aux = File(path + '/${widget.numero}.jpg');
    if (descargado || await aux.exists()) {
      if (await aux.exists()) {
        if (mounted) setState(() => sheetAvailable = true);
      } else {
        http.Response res = await http.get(Uri.parse(SheetsApi.sheetAvailable(widget.numero)));
        if (res.statusCode == 200) {
          if (mounted) setState(() => sheetAvailable = true);
          http.Response image = await http.get(Uri.parse(SheetsApi.getSheet(widget.numero)));
          await aux.writeAsBytes(image.bodyBytes);
        }
      }
    } else {
      http.Response res = await http.get(Uri.parse(SheetsApi.sheetAvailable(widget.numero)));
      print(res.statusCode);
      if (res.statusCode == 200) {
        if (mounted) setState(() => sheetAvailable = true);
        http.Response image = await http.get(Uri.parse(SheetsApi.getSheet(widget.numero)));
        await aux.writeAsBytes(image.bodyBytes);
      }
    }
    if (mounted)
      setState(() {
        sheetFile = aux;
        sheetReady = aux.existsSync();
      });
    return null;
  }

  Future<Null> getHimno() async {
    prefs = await SharedPreferences.getInstance();
    String databasesPath = (await getApplicationDocumentsDirectory()).path;
    String path = databasesPath + "/himnos.db";
    db = await openDatabase(path);

    List<Map<String, dynamic>> parrafos = await db.rawQuery('select * from parrafos where himno_id = ${widget.numero}');

    for (Map<String, dynamic> parrafo in parrafos) {
      acordes = parrafo['acordes'] != null;
      for (String linea in parrafo['parrafo'].split('\n')) {
        if (linea.length > max) max = linea.length;
      }
    }

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      initFontSizePortrait = (MediaQuery.of(context).size.width - 30) / max + 8;
      initFontSizeLandscape = (MediaQuery.of(context).size.height - 30) / max + 8;
    } else {
      initFontSizePortrait = (MediaQuery.of(context).size.height - 30) / max + 8;
      initFontSizeLandscape = (MediaQuery.of(context).size.width - 30) / max + 8;
    }

    List<Map<String, dynamic>> favoritosQuery = await db.rawQuery('select * from favoritos where himno_id = ${widget.numero}');
    List<Map<String, dynamic>> descargadoQuery = await db.rawQuery('select * from descargados where himno_id = ${widget.numero}');
    // List<Map<String,dynamic>> temaQuery = await db.rawQuery('select temas.tema, temas.id from tema_himnos join temas on temas.id = tema_himnos.tema_id where tema_himnos.himno_id = ${widget.numero}');
    // List<dynamic> subTemaQuery = await db.rawQuery('select sub_temas.id, sub_temas.sub_tema from sub_tema_himnos join sub_temas on sub_temas.id = sub_tema_himnos.sub_tema_id where sub_tema_himnos.himno_id = ${widget.numero}');
    setState(() {
      favorito = favoritosQuery.isNotEmpty;
      descargado = descargadoQuery.isNotEmpty;
      totalDuration = descargadoQuery.isNotEmpty ? descargadoQuery[0]['duracion'] : 0;
      estrofas = Parrafo.fromJson(parrafos);
      // tema = temaQuery == null || temaQuery.isEmpty ? '' : temaQuery[0]['tema'];
      // subTema = subTemaQuery.isNotEmpty ? subTemaQuery[0]['sub_tema'] : '';
      // temaId = subTemaQuery.isNotEmpty ? subTemaQuery[0]['id'] : temaQuery[0]['id'];
      tema = '';
      subTema = '';
      temaId = 1;
    });

    if (descargadoQuery.isEmpty && mounted) {
      http.get(Uri.parse(VoicesApi.voiceAvailable(widget.numero))).then((res) {
        if (res.statusCode == 200) {
          initVoces();
          setState(() => vozDisponible = true);
        } else
          setState(() => vozDisponible = false);
      }).catchError((onError) => print(onError));
    } else
      initVocesDownloaded();
    checkPartitura(databasesPath);
    await db.close();
    return null;
  }

  Future<Null> initVoces() async {
    setState(() => cargando = true);
    String path = (await getApplicationDocumentsDirectory()).path;
    List<bool> done = [false, false, false, false, false];
    cliente!
        .getUrl(Uri.parse(VoicesApi.getVoiceDuration(widget.numero, 'Soprano')))
        .then((request) => request.close())
        .then((response) => consolidateHttpClientResponseBytes(response))
        .then((bytes) async {
      totalDuration = (double.parse(Utf8Decoder().convert(bytes)) * 1000).ceil();
    });
    for (int i = 0; i < audioVoces.length; ++i) {
      cliente!
          .getUrl(Uri.parse(VoicesApi.getVoice(widget.numero, stringVoces[i])))
          .then((request) => request.close())
          .then((response) => consolidateHttpClientResponseBytes(response))
          .then((bytes) async {
        archivos[i] = File(path + '/${widget.numero}-${stringVoces[i]}.mp3');
        await archivos[i]!.writeAsBytes(bytes);
        done[i] = true;
        if (mounted) setState(() => ++doneCount);
      });
    }

    while (done.contains(false)) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    if (cliente != null && mounted)
      for (int i = 0; i < audioVoces.length; ++i) {
        bool success = false;
        while (!success) {
          try {
            await audioVoces[i].setSourceDeviceFile(path + '/${widget.numero}-${stringVoces[i]}.mp3');
            success = true;
          } catch (e) {
            success = false;
          }
        }

        await audioVoces[i].setReleaseMode(ReleaseMode.stop);
      }

    positionSubscription = audioVoces[4].onPositionChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          currentProgress = duration.inMilliseconds / totalDuration;
          currentDuration = duration;
        });
      }
    });
    completeSubscription = audioVoces[4].onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          start = false;
          currentProgress = 0.0;
        });
      }
    });

    if (cliente != null && mounted) {
      setState(() => cargando = false);
    } else {
      for (int i = 0; i < audioVoces.length; ++i) {
        audioVoces[i].release();
        if (archivos[i] != null && !descargado) if (archivos[i]!.existsSync()) archivos[i]!.deleteSync();
      }
    }
    return null;
  }

  void resumeVoces() {
    print(currentVoice);
    audioVoces[currentVoice].seek(Duration(milliseconds: (currentProgress * totalDuration).floor()));
    audioVoces[currentVoice].resume();
    setState(() => start = true);
  }

  void stopVoces() {
    setState(() {
      start = false;
      currentProgress = 0.0;
    });
    for (int i = 0; i < audioVoces.length; ++i) {
      audioVoces[i].pause();
      audioVoces[i].seek(Duration(milliseconds: 0));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    sheetController.dispose();
    switchModeController.dispose();
    WakelockPlus.disable();
    cliente = null;
    if (vozDisponible) {
      if (archivos[0] == null && !descargado) deleteVocesFiles();
      if (sheetFile.existsSync() && !descargado) sheetFile.deleteSync();
      for (int i = 0; i < audioVoces.length; ++i) {
        audioVoces[i].release();
        if (archivos[i] != null && !descargado) if (archivos[i]!.existsSync()) archivos[i]!.deleteSync();
      }
    }
  }

  void pauseVoces() {
    setState(() => start = false);
    for (int i = 0; i < audioVoces.length; ++i) {
      audioVoces[i].pause();
    }
  }

  void vocesSeek(double progress) async {
    setState(() => currentProgress = progress);
    await audioVoces[currentVoice].pause();
    await audioVoces[currentVoice].seek(Duration(milliseconds: (progress * totalDuration).floor()));
    if (start) resumeVoces();
  }

  void switchModes() async {
    modoVoces = !modoVoces;
    if (switchModeController.value == 1.0) {
      await switchModeController.animateTo(0.0, curve: Curves.fastOutSlowIn);
      setState(() {
        start = false;
        currentProgress = 0.0;
        audioVoces[currentVoice].stop();
        currentVoice = 4;
      });
    } else {
      await switchModeController.animateTo(1.0, curve: Curves.fastOutSlowIn);
    }
  }

  void toggleVoice(int index) async {
    cancelSubscription();
    if (start) {
      await audioVoces[currentVoice].pause();
    }
    if (currentVoice == 4) {
      positionSubscription = audioVoces[index].onPositionChanged.listen((Duration duration) {
        if (mounted) {
          setState(() {
            currentProgress = duration.inMilliseconds / totalDuration;
            currentDuration = duration;
          });
        }
      });
      completeSubscription = audioVoces[index].onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            start = false;
            currentProgress = 0.0;
          });
        }
      });
    } else if (currentVoice == index) {
      positionSubscription = audioVoces[4].onPositionChanged.listen((Duration duration) {
        if (mounted) {
          setState(() {
            currentProgress = duration.inMilliseconds / totalDuration;
            currentDuration = duration;
          });
        }
      });
      completeSubscription = audioVoces[4].onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            start = false;
            currentProgress = 0.0;
          });
        }
      });
    } else {
      positionSubscription = audioVoces[index].onPositionChanged.listen((Duration duration) {
        if (mounted) {
          setState(() {
            currentProgress = duration.inMilliseconds / totalDuration;
            currentDuration = duration;
          });
        }
      });
      completeSubscription = audioVoces[index].onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            start = false;
            currentProgress = 0.0;
          });
        }
      });
    }
    currentVoice = currentVoice == index ? 4 : index;
    if (start) {
      resumeVoces();
    }
    setState(() {});
  }

  void toggleFavorito() {
    initDB().then((db) async {
      await db.transaction((action) async {
        if (favorito) {
          await action.rawDelete('delete from favoritos where himno_id = ${widget.numero}');
        } else {
          await action.rawInsert('insert into favoritos values (${widget.numero})');
        }
      });
      await db.close();
      setState(() => favorito = !favorito);
    });
  }

  void cancelSubscription() {
    positionSubscription.cancel();
    completeSubscription.cancel();
  }

  void toggleDescargado() {
    initDB().then((db) async {
      await db.transaction((action) async {
        if (descargado) {
          await action.rawDelete('delete from descargados where himno_id = ${widget.numero}');
        } else {
          await action.rawInsert('insert into descargados values (${widget.numero}, $totalDuration)');
        }
      });
      await db.close();
      setState(() => descargado = !descargado);
    });
  }

  Widget musicSheetLayout() {
    return AnimatedContainer(
      curve: sheet ? Curves.fastLinearToSlowEaseIn : Curves.fastOutSlowIn,
      duration: Duration(milliseconds: sheet ? 500 : 1500),
      transform: Matrix4.translationValues(sheet ? 0.0 : 5000, 0.0, 0.0),
      height: MediaQuery.of(context).size.height - (modoVoces ? 200 : 0),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (currentOrientation == null) {
            currentOrientation = orientation;
          }
          if (currentOrientation != orientation) {
            currentOrientation = null;
            sheetController = PhotoViewController();
            sheet = false;
            Future.delayed(Duration(milliseconds: 0)).then((value) {
              setState(() => sheet = true);
            });
          }

          Widget loadingChild = Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  descargado ? 'Cargando partitura' : 'Descargando partitura',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  textScaleFactor: 1.2,
                )
              ],
            ),
          );

          return currentOrientation == null
              ? Container()
              : !sheetReady
                  ? loadingChild
                  : PhotoView(
                      controller: sheetController,
                      imageProvider: FileImage(sheetFile),
                      basePosition: Alignment.topCenter,
                      // scaleStateControllerlate: scaleController,
                      initialScale: orientation == Orientation.portrait ? PhotoViewComputedScale.contained : PhotoViewComputedScale.covered,
                      loadingBuilder: (context, _) => loadingChild,
                      // loadingChild: loadingChild,
                      backgroundDecoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    );
        },
      ),
    );
  }

  Widget voicesControlsLayout() {
    List<Widget> controlesLayout = generateControlesLayout();

    List<Widget> buttonLayout = [
      VoicesProgressBar(
        currentProgress: currentProgress,
        duration: totalDuration,
        onDragStart: cancelSubscription,
        onSelected: (double progress) {
          positionSubscription = audioVoces[currentVoice].onPositionChanged.listen((Duration duration) {
            setState(() {
              currentProgress = duration.inMilliseconds / totalDuration;
              currentDuration = duration;
            });
          });
          completeSubscription = audioVoces[currentVoice].onPlayerComplete.listen((_) {
            setState(() {
              start = false;
              currentProgress = 0.0;
            });
          });
          print(progress);
          setState(() => currentProgress = progress);
          vocesSeek(progress);
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            shape: CircleBorder(),
            child: IconButton(
              onPressed: () {
                double newProgress = currentProgress - 0.1;
                if (newProgress <= 0.0)
                  vocesSeek(0.0);
                else
                  vocesSeek(currentProgress - 0.1);
              },
              icon: Icon(
                Icons.fast_rewind,
                color: isAndroid() ? null : ScopedModel.of<TemaModel>(context).getScaffoldTextColor(),
              ),
            ),
            onPressed: () {},
          ),
          start
              ? RawMaterialButton(
                  shape: CircleBorder(),
                  child: IconButton(
                    onPressed: pauseVoces,
                    icon: Icon(
                      Icons.pause,
                      color: isAndroid() ? null : ScopedModel.of<TemaModel>(context).getScaffoldTextColor(),
                    ),
                  ),
                  onPressed: () {},
                )
              : RawMaterialButton(
                  shape: CircleBorder(),
                  child: IconButton(
                    onPressed: !cargando
                        ? () {
                            resumeVoces();
                          }
                        : null,
                    icon: Icon(
                      Icons.play_arrow,
                      color: isAndroid() ? null : ScopedModel.of<TemaModel>(context).getScaffoldTextColor(),
                    ),
                  ),
                  onPressed: () {},
                ),
          RawMaterialButton(
            shape: CircleBorder(),
            child: IconButton(
              onPressed: () {
                double newProgress = currentProgress + 0.1;
                if (newProgress >= 1.0)
                  vocesSeek(1.0);
                else
                  vocesSeek(currentProgress + 0.1);
              },
              icon: Icon(
                Icons.fast_forward,
                color: isAndroid() ? null : ScopedModel.of<TemaModel>(context).getScaffoldTextColor(),
              ),
            ),
            onPressed: () {},
          ),
        ],
      )
    ];

    for (Widget widget in buttonLayout) controlesLayout.add(widget);

    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: FractionalTranslation(
        translation: Offset(0.0, 1.0 - switchModeController.value),
        child: Card(
          margin: EdgeInsets.all(0.0),
          color: !isAndroid() ? ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor() : null,
          elevation: 10.0,
          child: !cargando
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: controlesLayout,
                  ),
                )
              : Container(
                  height: smallDevice(context) ? 185.0 : 140.0,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: isAndroid()
                          ? LinearProgressIndicator(
                              value: 0.25 * doneCount,
                              backgroundColor: Colors.grey[400],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryIconTheme.color == Colors.black ? Colors.black : Theme.of(context).primaryColor,
                              ),
                            )
                          : CupertinoActivityIndicator(
                              animating: true,
                              radius: 20.0,
                            ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> generateControlesLayout() {
    List<String> labels =
        smallDevice(context) ? ['   Soprano  ', '    Tenor    ', 'Contra Alto', '     Bajo     '] : ['Soprano', 'Tenor', 'Contra Alto', 'Bajo'];

    List<Widget> buttons = [];

    for (int i = 0; i < labels.length; ++i) {
      buttons.add(
        BotonVoz(
          voz: labels[i],
          activo: currentVoice == i || currentVoice == 4,
          onPressed: () => toggleVoice(i),
          mainColor: TemaModel.of(context).getAccentColor(),
          mainColorContrast: TemaModel.of(context).getAccentColorText(),
        ),
      );
    }

    if (smallDevice(context)) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buttons[0], buttons[1]],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buttons[2], buttons[3]],
        )
      ];
    }

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      )
    ];
  }

  Widget materialLayout() {
    if (prefs != null) {
      return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              vozDisponible || sheetAvailable
                  ? IconButton(
                      onPressed: toggleDescargado,
                      icon: descargado
                          ? Icon(
                              Icons.delete,
                            )
                          : Icon(
                              Icons.get_app,
                            ),
                    )
                  : Container(),

              // Activar modo partituras
              sheetAvailable
                  ? IconButton(
                      onPressed: () {
                        // Future.delayed(Duration(milliseconds: 500)).then((_) => sheetController.reset());
                        setState(() => sheet = !sheet);
                      },
                      icon: Icon(Icons.music_note),
                    )
                  : Container(),

              IconButton(
                onPressed: toggleFavorito,
                icon: favorito
                    ? Icon(
                        Icons.star,
                      )
                    : Icon(
                        Icons.star_border,
                      ),
              ),
            ],
            title: Tooltip(
              message: '${widget.numero} - ${widget.titulo}',
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.titulo}',
                      textScaleFactor: 0.9,
                    ),
                    Text(
                      '${widget.numero}',
                      textScaleFactor: 0.8,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(4.0), child: Container()),
          ),
          body: Stack(
            children: <Widget>[
              BodyHimno(
                alignment: prefs!.getString('alignment') ?? 'Izquierda',
                estrofas: estrofas,
                initFontSizePortrait: initFontSizePortrait,
                initFontSizeLandscape: initFontSizeLandscape,
                switchValue: switchModeController.value,
                tema: tema,
                subTema: subTema,
                temaId: temaId,
              ),
              WillPopScope(
                onWillPop: () async {
                  bool goBack = true;
                  if (sheet) {
                    setState(() => sheet = !sheet);
                    goBack = false;
                  }
                  return goBack;
                },
                child: musicSheetLayout(),
              ),
              voicesControlsLayout(),
            ],
          ),
          floatingActionButton: vozDisponible
              ? Padding(
                  padding: EdgeInsets.only(bottom: smallDevice(context) ? switchModeController.value * 175 : switchModeController.value * 130),
                  child: FloatingActionButton(
                    key: UniqueKey(),
                    backgroundColor: modoVoces ? Colors.redAccent : TemaModel.of(context).getAccentColor(),
                    onPressed: switchModes,
                    child: Stack(
                      children: <Widget>[
                        Transform.scale(
                          scale: 1.0 - switchModeController.value,
                          child: Icon(Icons.play_arrow, size: 40.0),
                        ),
                        Transform.scale(
                          scale: 0.0 + switchModeController.value,
                          child: Icon(Icons.redo, color: Colors.white, size: 40.0),
                        ),
                      ],
                    ),
                  ),
                )
              : null);
    }

    return Scaffold(
      appBar: AppBar(),
    );
  }

  Widget cupertinoLayout() {
    final _tema = TemaModel.of(context);

    List<Widget> modalButtons = [
      CupertinoActionSheetAction(
        isDestructiveAction: descargado,
        onPressed: () {
          toggleDescargado();
          Navigator.of(context).pop();
        },
        child: Text(descargado ? 'Eliminar' : 'Descargar', style: TextStyle(color: _tema.getScaffoldTextColor())),
      ),
    ];

    if (vozDisponible) {
      modalButtons.add(CupertinoActionSheetAction(
        onPressed: () {
          switchModes();
          Navigator.of(context).pop();
        },
        child: Text(modoVoces ? 'Ocultar Voces' : 'Mostrar Voces', style: TextStyle(color: _tema.getScaffoldTextColor())),
      ));
    }

    if (sheetAvailable) {
      modalButtons.add(CupertinoActionSheetAction(
        onPressed: () {
          Future.delayed(Duration(milliseconds: 500)).then((_) => sheetController.reset());
          setState(() => sheet = !sheet);
          Navigator.of(context).pop();
        },
        child: Text(sheet ? 'Ocultar Partitura' : 'Mostrar Partitura', style: TextStyle(color: _tema.getScaffoldTextColor())),
      ));
    }

    return CupertinoPageScaffold(
      // backgroundColor: ScopedModel.of<TemaModel>(context).getScaffoldBackgroundColor(),
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: true,
        // actionsForegroundColor: ScopedModel.of<TemaModel>(context).getTabTextColor(),
        // backgroundColor: ScopedModel.of<TemaModel>(context).getTabBackgroundColor(),
        middle: Text('${widget.numero} - ${widget.titulo}'),
        trailing: prefs != null
            ? Transform.translate(
                offset: Offset(20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: toggleFavorito,
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: favorito
                          ? Icon(
                              Icons.star,
                              size: 30.0,
                              color: _tema.getAccentColorText(),
                            )
                          : Icon(
                              Icons.star_border,
                              size: 30.0,
                              color: _tema.getAccentColorText(),
                            ),
                    ),
                    CupertinoButton(
                      disabledColor: Colors.black.withOpacity(0.5),
                      onPressed: vozDisponible || sheetAvailable
                          ? () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) => CupertinoActionSheet(
                                  cancelButton: CupertinoActionSheetAction(
                                    isDestructiveAction: true,
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  actions: modalButtons,
                                ),
                              );
                            }
                          : null,
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Icon(
                        Icons.more_vert,
                        size: 30.0,
                        color: _tema.getAccentColorText(),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      child: prefs != null
          ? Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: switchModeController.value * (smallDevice(context) ? 185.0 : 140.0)),
                  child: BodyHimno(
                    switchValue: switchModeController.value,
                    alignment: prefs!.getString('alignment') ?? 'Izquierda',
                    estrofas: estrofas,
                    initFontSizePortrait: initFontSizePortrait,
                    initFontSizeLandscape: initFontSizeLandscape,
                    tema: tema,
                    subTema: subTema,
                    temaId: temaId,
                  ),
                ),
                musicSheetLayout(),
                voicesControlsLayout(),
              ],
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAndroid() ? materialLayout() : cupertinoLayout();
  }
}
