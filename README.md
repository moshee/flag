A simple, barebones command-line flag parser in less than 100 sloc. Few features and little configurability. A tiny library for tiny projects.

#### Example

The code:

```ruby
#/usr/bin/env ruby
# encoding: utf-8

require 'flag'

flags = Flags.new do |flag|
  flag.string 'prefix', '', 'Prefix'
  flag.bool   'h', false, 'Show help'
end

if ARGV.empty? or flags['h']
  puts 'Usage: prefix [-prefix PREFIX] files...'
  flags.help
  exit 1
end

puts flags['prefix'] + flags.args.join(' ')
```

Run it like:

```
$ ./prefix.rb -h
Usage: prefix [-prefix PREFIX] files...
  -h       Show help [false]
  -prefix  Prefix [""]
$ ./prefix.rb -prefix 'Hello, ' 'World!'
Hello, World!
```
