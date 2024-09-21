<p align="center">
  <a href="http://blog.codinghorror.com/the-best-code-is-no-code-at-all/">
    <img alt="Lines of Code" src="https://img.shields.io/badge/loc-1039-47d299.svg" />
  </a>
  <a href="https://github.com/testdouble/standard">
    <img alt="Ruby Style" src="https://img.shields.io/badge/style-standard-168AFE?logo=ruby&logoColor=FE1616" />
  </a>
  <a href="https://github.com/sponsors/hopsoft">
    <img alt="Sponsors" src="https://img.shields.io/github/sponsors/hopsoft?color=eb4aaa&logo=GitHub%20Sponsors" />
  </a>
  <a href="https://twitter.com/hopsoft">
    <img alt="Twitter Follow" src="https://img.shields.io/twitter/url?label=%40hopsoft&style=social&url=https%3A%2F%2Ftwitter.com%2Fhopsoft">
  </a>
</p>

# Fmt

#### Template engine based on native Ruby String formatting mechanics

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

- [Why?](#why)
- [Setup](#setup)
- [Usage](#usage)
  - [Formatting](#formatting)
  - [Filters](#filters)
  - [Embeds](#embeds)
- [Sponsors](#sponsors)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Why?

I'm using `Fmt` to help craft beautiful CLI applications with Ruby. _Plus it's fun._

## Setup

```
bundle add rainbow # <- optional
bundle add fmt
```

## Usage

Simply create a string with Ruby's format specifiers as you'd normally do with `sprintf`.

- `"%s"`
- `"%{variable}"`
- `"%<variable>s"`

Formatting `macros` can be appended to the format specifier like so.

```ruby
Fmt("%s|>capitalize", "hello world!") # => "Hello world!"
Fmt("%{msg}|>capitalize", msg: "hello world!") # => "Hello world!"
```

Macros can accept arguments.

```ruby
Fmt("%s|>prepend('Hello ')", "world!") # => "Hello world!"
Fmt("%{msg}|>prepend('Hello ')", msg: "world!") # => "Hello world!"
```

Macros can be chained `pipeline` to construct a formatting `pipeline`.

```ruby
Fmt("%s|>prepend('Hello ')|>ljust(32, '.')|>upcase", "world!") # => "HELLO WORLD!...................."
Fmt("%{msg}|>prepend('Hello ')|>ljust(32, '.')|>upcase", msg: "world!") # => "HELLO WORLD!...................."
```

> [!NOTE]
> Pipelines are processed left to right. The return value from a preceeding `macro` is the starting point for the next.

`Fmt` arguments and `macro` return values can be any type.

```ruby
Fmt("%p|>partition(/:/)|>last|>delete_suffix('>')", Object.new) # => "0x000000011f33bc68"
```

### Supported Methods

Most public instance methods on the following classes are supported.

- `Array`
- `Date`
- `DateTime`
- `FalseClass`
- `Float`
- `Hash`
- `Integer`
- `NilClass`
- `Range`
- `Regexp`
- `Set`
- `StandardError`
- `String`
- `Struct`
- `Symbol`
- `Time`
- `TrueClass`

> [!TIP]
> If you're using libraries like ActiveSupport, support for extension methods is also available.

#### Rainbow GEM

Color and style support is available if your project includes the [Rainbow GEM](https://github.com/ku1ik/rainbow).

```ruby
template = "%{msg}|>cyan|>bold|>underline" # <- templates are just format strings
Fmt(template, msg: "Hello World!")
#=> "\e[36m\e[1m\e[4mHello World!\e[0m"
```

### Composition

Templates can include multiple format strings.

```ruby
template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
Fmt(template, date: Time.now, msg: "this is cool")
#=> "Date: \e[35m2024-09-20\e[0m \e[1mThis Is Cool\e[0m"
```

---

## TODO: Edit content below...

---

Multiline example:

```ruby
template = <<~T
  Date: %{date}.10s|underline

  Greetings, %{name}upcase|bold

  %{message}strip|green
T

Fmt template, date: Time.now, name: "Hopsoft", message: "This is neat!"

#=> "Date: \e[4m2024-07-26\e[0m\n\nGreetings, \e[1mHOPSOFT\e[0m\n\n\e[32mThis is neat!\e[0m\n"
```

![CleanShot 2024-07-26 at 01 44 30@2x](https://github.com/user-attachments/assets/8926009c-7cf1-4140-9a2a-6ed718d50926)

### Filters

You can also add your own filters to Fmt by calling `Fmt.add_filter(:name, &block)`.
The block accepts an `Object` and returns a `String`.

```ruby
require "rainbow"
require "fmt"

Fmt.add_rainbow_filters
Fmt.add_filter(:ljust) { |val| "".ljust 14, val.to_s }

template = <<~T
  %{prefix}ljust|faint
  %{message}bold
  %{suffix}ljust|faint
T

Fmt template, prefix: "#", message: "Give it a try!", suffix: "#"

#=> "\e[2m##############\e[0m\n\e[1mGive it a try!\e[0m\n\e[2m##############\e[0m\n"
```

![CleanShot 2024-07-26 at 01 46 26@2x](https://github.com/user-attachments/assets/bd1d67c6-1182-428b-be05-756f3d330f67)

### Embeds

Templates can be embedded or nested within other templates... as deep as needed!
Just wrap the embedded template in double curly braces: `{{EMBEDDED TEMPLATE HERE}}`

```ruby
require "rainbow"
require "fmt"

Fmt.add_rainbow_filters

template = "%{value}lime {{%{embed_value}red|bold|underline}}"
Fmt template, value: "Outer", embed_value: "Inner"

#=> "\e[38;5;46mOuter\e[0m \e[31m\e[1m\e[4mInner\e[0m"
```

![CleanShot 2024-07-29 at 02 42 19@2x](https://github.com/user-attachments/assets/f67dd215-b848-4a23-bd73-72822cb7d970)

```ruby
template = <<~T
  |--%{value}yellow|bold|underline
  |  |--{{%{inner_value}green|bold|underline
  |  |  |--{{%{deep_value}blue|bold|underline
  |  |  |  |-- We're in deep!}}}}
T

Fmt template, value: "Outer", inner_value: "Inner", deep_value: "Deep"

#=> "|--\e[33m\e[1m\e[4mOuter\e[0m\n|  |--\e[32m\e[1m\e[4mInner\e[0m\n|  |  |--\e[34m\e[1m\e[4mDeep\e[0m\n|  |  |  |-- We're in deep!\n"
```

![CleanShot 2024-07-29 at 02 45 27@2x](https://github.com/user-attachments/assets/1b933bf4-a62d-4913-b817-d6c69b0e7028)

## Sponsors

<p align="center">
  <em>Proudly sponsored by</em>
</p>
<p align="center">
  <a href="https://www.clickfunnels.com?utm_source=hopsoft&utm_medium=open-source&utm_campaign=fmt">
    <img src="https://images.clickfunnel.com/uploads/digital_asset/file/176632/clickfunnels-dark-logo.svg" width="575" />
  </a>
</p>
