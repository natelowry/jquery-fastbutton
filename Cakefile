{exec} = require 'child_process'

task 'build', ->
  exec 'coffeelint src/fastbutton.coffee',
        customFds: [0..2]
  exec 'coffee --output bin --compile src',
        customFds: [0..2]
