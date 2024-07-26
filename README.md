# Fmt

Fmt is a simple template engine based on native Ruby String formatting mechanics.

## Why?

I'm currenly using this to help build beautiful CLI applications with Ruby. Plus it's fun.

## Setup

```
bundle add fmt
bundle add rainbow # optional
```

## Usage

Simply create a string with embedded formatting syntax as you'd normally do with `sprintf` or `format`.
i.e. `"%{...}"`

Filters can be chained after the placeholder like so `"%{...}FILTER|FILTER|FILTER"`
Filters are processed in the order they are specified.

You can use native Ruby formatting as well as String methods like `upcase`, `reverse`, `strip`, etc.
If you have the Rainbow GEM installed, you can also use Rainbow formatting like `red`, `bold`, etc.

### Rendering

Basic example:

```ruby
require "fmt"

template = "Hello %{name}cyan|bold"
result = Fmt(template, name: "World")
#=> "Hello \e[36m\e[1mWorld\e[0m"
```

Mix and match native formatting with Rainbow formatting:

```ruby
require "fmt"

template = "Date: %{date}.10s|magenta"
result = Fmt(template, date: Time.now)
#=> "Date: \e[35m2024-07-26\e[0m"
```

Multiline example:

```ruby
template = <<~T
  Date: %{date}.10s|underline

  Greetings, %{name}upcase|bold

  %{message}strip|green
T

result = Fmt(template, date: Time.now, name: "Hopsoft", message: "This is neat!")
#=> "Date: \e[4m2024-07-26\e[0m\n\nGreetings, \e[1mHOPSOFT\e[0m\n\n\e[32mThis is neat!\e[0m\n"
```

### Filters

You can also add your own filters to Fmt by calling `Fmt.add_filter(:name, &block)`.
The block accepts a string and should return a replacement string.

```ruby
Fmt.add_filter(:repeat20) { |str| str * 20 }

template = <<~T
  %{head}repeat20|faint
  %{message}bold
  %{tail}repeat20|faint
T

result = Fmt(template, head: "#", message: "Give it a try!", tail: "#")
#=> "\e[2m####################\e[0m\n\e[1mGive it a try!\e[0m\n\e[2m####################\e[0m\n"
```
