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

- General purpose templating
- Help craft beautiful CLI applications in Ruby

## Setup

```sh
bundle add rainbow # <- optional
bundle add fmt
```

```ruby
require "rainbow" # <- optional
require "fmt"
```

## Usage

Simply create a string with Ruby's [format specifiers](https://ruby-doc.org/3.3.5/format_specifications_rdoc.html) as you'd normally do for `sprintf`.

- `"%s"`
- `"%{variable}"`
- `"%<variable>s"`

_Any string can be considered a template when using Fmt._

### Macros

Formatting `macros` can be appended to the format specifier like so.

<!-- test_e798c3 -->

```ruby
Fmt("%s|>capitalize", "hello world!") # => "Hello world!"
Fmt("%{msg}|>capitalize", msg: "hello world!") # => "Hello world!"
```

Macros can accept arguments.

<!-- test_1707d2  -->

```ruby
Fmt("%s|>prepend('Hello ')", "world!") # => "Hello world!"
Fmt("%{msg}|>prepend('Hello ')", msg: "world!") # => "Hello world!"
```

### Pipelines

Macros can be chained to create a formatting pipeline.

<!-- test_425625 -->

```ruby
Fmt("%s|>prepend('Hello ')|>ljust(32, '.')|>upcase", "world!") # => "HELLO WORLD!...................."
Fmt("%{msg}|>prepend('Hello ')|>ljust(32, '.')|>upcase", msg: "world!") # => "HELLO WORLD!...................."
```

> [!NOTE]
> Pipelines are processed left to right. The return value from the preceeding macro is the starting value for the next macro.

Arguments and return values can be any type.

<!-- test_f55ae2 -->

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
> If you're using libraries like ActiveSupport that extend these classes, extension methods will also available if the library is required before Fmt.

#### Rainbow GEM

Color and style support is available if your project includes the [Rainbow GEM](https://github.com/ku1ik/rainbow).

<!-- test_19c8ca -->

```ruby
template = "%{msg}|>cyan|>bold|>underline"
Fmt(template, msg: "Hello World!")
#=> "\e[36m\e[1m\e[4mHello World!\e[0m"
```

### Composition

You can mix and match macros that target any type within a pipeline.

Templates can also include multiple format strings with their own distinct pipelines.

<!-- test_0dbfcd -->

```ruby
template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
Fmt(template, date: Time.now, msg: "this is cool")
#=> "Date: \e[35m2024-09-20\e[0m \e[1mThis Is Cool\e[0m"
```

#### Embedded Templates

Embedded templates can be nested within other templates... as deep as needed!

<!-- test_efee7a -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold}}"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m"
```

Embeds can also have their own distinct pipelines.

<!-- test_abb7ea -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold}}|>underline"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1m\e[4mI'm embedded!\e[0m"
```

Embeds can be deeply nested.

<!-- test_79e924 -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold {{%{deep_embed}|>red|>bold}}}}"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!", deep_embed: "And I'm deeply embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m \e[31m\e[1mAnd I'm deeply embedded!\e[0m"
```

Embeds can also span multiple lines.

<!-- test_054526 -->

```ruby
template = <<~T
  %{one}|>red {{
    %{two}|>blue {{
      %{three}|>green
    }}
  }}|>bold
T
Fmt(template, one: "Red", two: "Blue", three: "Green")
#=> "\e[31mRed\e[0m \e[1m\n  \e[34mBlue\e[0m \n    \e[32mGreen\e[0m"
```

### Extending Fmt

You can also add your own filters with `Fmt.register([CLASS, NAME], &block)`.

<!-- test_2cacce -->

```ruby
Fmt.register([Object, :shuffle]) { |*args, **kwargs| to_s.chars.shuffle.join }
Fmt("%s|>shuffle", "This don't make no sense.")
#=> "de.nnoTtsnh'oeek  ssim a "
```

You can also run a Ruby block with temporary filters if you don't want to officially register them.

> [!TIP]
> This also allows you to override existing filters for the duration of the block.

<!-- test_7df4eb -->

```ruby
Fmt.with_overrides([Object, :red] => proc { |*args, **kwargs| Rainbow(self).crimson.bold }) do
  Fmt("%s|>red", "This is customized red!")
  #=> "\e[38;5;197m\e[1mThis is customized red!\e[0m"
end

Fmt("%s|>red", "This is original red!")
#=> "\e[31mThis is original red!\e[0m"
```

## Sponsors

<p align="center">
  <em>Proudly sponsored by</em>
</p>
<p align="center">
  <a href="https://www.clickfunnels.com?utm_source=hopsoft&utm_medium=open-source&utm_campaign=fmt">
    <img src="https://images.clickfunnel.com/uploads/digital_asset/file/176632/clickfunnels-dark-logo.svg" width="575" />
  </a>
</p>
