const WordExtractor = require("word-extractor")
const fs = require('fs')

var extractor = new WordExtractor()

let libros = []

let texto = fs.readFileSync('./librosDeLaBiblia.txt', {encoding: 'UTF-8'})
libros = texto.split('\r\n')

// fs.writeFileSync('./init.txt', '')

texto = fs.readFileSync('./init.txt', {encoding: 'UTF-8'})

// while(texto.indexOf('\t') > 0) {
//   texto = texto.replace('\t', '')
// }

// fs.writeFileSync('./init.txt', texto)

let himnos = []

texto = texto.split('\n')

let index = 0;

for (let i = 0; i < texto.length; ++i) {
  for (libro of libros) {
    if (texto[i].indexOf(libro) > 0) {
      let himno = ''
      for (let j = index; j < i; ++j) {
        himno += texto[j]
        himno += '\n'
      }
      himnos.push(himno)
      index = i + 1
      break
    }
  }
}

let himno = ''
for (let i = index; i < texto.length; ++i) {
  himno += texto[i]
  himno += '\n'
}

himnos.push(himno)

let parrafosInit = ''

console.log(himnos[himnos.length - 1])

for (let i = 0; i < himnos.length; ++i) {
  let currentParrafo = 1;
  let coros = []
  let parrafos = []

  while(himnos[i].indexOf('coro') > 0 && !coros.includes(himnos[i].indexOf('coro'))) {
    coros.push(himnos[i].indexOf('coro'))
  }

  while(himnos[i].indexOf(currentParrafo) > 0) {
    parrafos.push(himnos[i].indexOf(currentParrafo))
    ++currentParrafo
  }

  console.log('himno: ', i + 8)
  console.log('coros:', coros)
  console.log('parrafos', parrafos)
  
}


// extractor.extract("514-Himnos-del-Evangelio.doc")
//   .then((doc) => {
//     let body = doc.getBody();
//     let himnos = []
//     let currentHimno = 8

//     body = body.substring(body.indexOf('	1			¡'), body.indexOf('518	Mateo 26.36'))
//     while(body.indexOf('') > 0) {
//       body = body.replace('', '\n')
//     }

//     fs.writeFileSync('./init.txt', body)

//     body = body.split('\n')

//     let index = 0;

//     for (let i = 0; i < body.lenght; ++i) {
//       for (libro of libros) {
//         if (body[i].indexOf(libro) > 0) {

//         }
//       }
//     }

    

//     console.log(body[0])

//     himnos.push()



//   });