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

```ruby
"%{...}"
```

Filters can be chained after the placeholder like so.

```ruby
"%{...}FILTER|FILTER|FILTER"
```

> [!NOTE]
> Filters are processed in the order they are specified.

You can use [native Ruby formatting](https://docs.ruby-lang.org/en/master/format_specifications_rdoc.html) as well as String methods like `upcase`, `reverse`, `strip`, etc.
If you have the [Rainbow GEM](https://github.com/ku1ik/rainbow) installed, you can also use Rainbow formatting like `red`, `bold`, etc.

### Rendering

Basic example:

```ruby
require "fmt"

template = "Hello %{name}cyan|bold"
result = Fmt(template, name: "World")
#=> "Hello \e[36m\e[1mWorld\e[0m"
```

![CleanShot 2024-07-26 at 01 40 33@2x](https://github.com/user-attachments/assets/04ff90e6-254a-42d4-9169-586ac24b82f0)

Mix and match native formatting with Rainbow formatting:

```ruby
require "fmt"

template = "Date: %{date}.10s|magenta"
result = Fmt(template, date: Time.now)
#=> "Date: \e[35m2024-07-26\e[0m"
```

![CleanShot 2024-07-26 at 01 42 53@2x](https://github.com/user-attachments/assets/507913b0-826b-4526-9c79-27f766c904b3)

Multiline example:

```ruby
require "fmt"

template = <<~T
  Date: %{date}.10s|underline

  Greetings, %{name}upcase|bold

  %{message}strip|green
T

result = Fmt(template, date: Time.now, name: "Hopsoft", message: "This is neat!")
#=> "Date: \e[4m2024-07-26\e[0m\n\nGreetings, \e[1mHOPSOFT\e[0m\n\n\e[32mThis is neat!\e[0m\n"
```

![CleanShot 2024-07-26 at 01 44 30@2x](https://github.com/user-attachments/assets/8926009c-7cf1-4140-9a2a-6ed718d50926)

### Filters

You can also add your own filters to Fmt by calling `Fmt.add_filter(:name, &block)`.
The block accepts a string and should return a replacement string.

```ruby
require "fmt"

Fmt.add_filter(:repeat20) { |str| str * 20 }

template = <<~T
  %{head}repeat20|faint
  %{message}bold
  %{tail}repeat20|faint
T

result = Fmt(template, head: "#", message: "Give it a try!", tail: "#")
#=> "\e[2m####################\e[0m\n\e[1mGive it a try!\e[0m\n\e[2m####################\e[0m\n"
```

![CleanShot 2024-07-26 at 01 46 26@2x](https://github.com/user-attachments/assets/bd1d67c6-1182-428b-be05-756f3d330f67)
