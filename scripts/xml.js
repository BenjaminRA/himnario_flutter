const fs = require('fs')
var convert = require('xml-js');

const folder = fs.readdirSync('./himnos')

let init = ''


for (let i = 0; i < folder.length; ++i) {
  var xml = fs.readFileSync('./himnos/' + folder[i], 'utf16le')

  var himno = JSON.parse(convert.xml2json(xml, {compact: true, spaces: 4})).song.lyrics.verse

  for(verso of himno) {
    if ((verso._attributes.name).indexOf('x') >= 0) break
    const coro = (verso._attributes.name).indexOf('c') >= 0 
    init += `${i+1}- ${coro ? 'true' : 'false'}-\n`

  for(linea of verso.lines._text) {
      init += linea
      init += '\n'
    }
    init += '\n'
  }
  fs.writeFileSync('./init.txt', init)
}

