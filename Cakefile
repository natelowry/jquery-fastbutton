{spawn} = require 'child_process'

task 'watch', ->
  spawn 'coffee',
        ['--output', 'bin', '--watch', '--compile', 'src'],
        customFds: [0..2]

task 'build', ->
  spawn 'coffeelint', ['src/fastbutton.coffee'],
        customFds: [0..2]
  spawn 'coffee',
        ['--output', 'bin', '--compile', 'src'],
        customFds: [0..2]

task 'build-demo', ->
  invoke 'build'
  spawn 'haml',
        ['src/index.haml', 'bin/index.html'],
        customFds: [0..2]

