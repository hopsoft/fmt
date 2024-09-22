<p align="center">
  <a href="http://blog.codinghorror.com/the-best-code-is-no-code-at-all/">
    <img alt="Lines of Code" src="https://img.shields.io/badge/loc-1042-47d299.svg" />
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

# CLI Templating System and String Formatter

**Fmt** is a powerful and flexible templating system and string formatter for Ruby, designed to streamline the creation of command-line interfaces and enhance general-purpose string formatting.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Getting Started](#getting-started)
  - [Usage](#usage)
    - [Macros](#macros)
    - [Pipelines](#pipelines)
    - [Supported Methods](#supported-methods)
      - [Rainbow GEM](#rainbow-gem)
    - [Composition](#composition)
      - [Embedded Templates](#embedded-templates)
    - [Customizing Fmt](#customizing-fmt)
  - [Kernel Refinement](#kernel-refinement)
    - [`fmt(object, *pipeline)`](#fmtobject-pipeline)
    - [`fmt_print(object, *pipeline)`](#fmt_printobject-pipeline)
    - [`fmt_puts(object, *pipeline)`](#fmt_putsobject-pipeline)
  - [Performance](#performance)
  - [Sponsors](#sponsors)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Getting Started

Install the required dependencies:

```sh
bundle add rainbow # <- optional, for color support
bundle add fmt
```

Then, require the necessary libraries in your Ruby file:

```ruby
require "rainbow" # <- optional, for color support
require "fmt"
```

## Usage

Fmt uses Ruby's native [format specifiers](https://ruby-doc.org/3.3.5/format_specifications_rdoc.html) to create templates:

- `"%s"` - Standard format specifier
- `"%{variable}"` - Named format specifier
- `"%<variable>s"` - Named format specifier _(alternative syntax)_

### Macros

Formatting macros are appended to format specifiers to modify the output:

<!-- test_e798c3 -->

```ruby
Fmt("%s|>capitalize", "hello world!") # => "Hello world!"
Fmt("%{msg}|>capitalize", msg: "hello world!") # => "Hello world!"
```

Macros can accept arguments:

<!-- test_1707d2  -->

```ruby
Fmt("%s|>prepend('Hello ')", "world!") # => "Hello world!"
Fmt("%{msg}|>prepend('Hello ')", msg: "world!") # => "Hello world!"
```

### Pipelines

Macros can be chained to create a formatting pipeline:

<!-- test_425625 -->

```ruby
Fmt("%s|>prepend('Hello ')|>ljust(32, '.')|>upcase", "world!") # => "HELLO WORLD!...................."
Fmt("%{msg}|>prepend('Hello ')|>ljust(32, '.')|>upcase", msg: "world!") # => "HELLO WORLD!...................."
```

Pipelines are processed left to right, with the return value from the preceding macro serving as the starting value for the next macro.

Arguments and return values can be of any type:

<!-- test_f55ae2 -->

```ruby
Fmt("%p|>partition(/:/)|>last|>delete_suffix('>')", Object.new) # => "0x000000011f33bc68"
```

### Supported Methods

Most public instance methods on the following classes are supported:

`Array`, `Date`, `DateTime`, `FalseClass`, `Float`, `Hash`, `Integer`, `NilClass`, `Range`, `Regexp`, `Set`, `StandardError`, `String`, `Struct`, `Symbol`, `Time`, `TrueClass`

Extension methods from libraries like ActiveSupport will also be available if the library is required before Fmt.

#### Rainbow GEM

Color and style support is available if your project includes the [Rainbow GEM](https://github.com/ku1ik/rainbow):

<!-- test_19c8ca -->

```ruby
template = "%{msg}|>cyan|>bold|>underline"
Fmt(template, msg: "Hello World!")
#=> "\e[36m\e[1m\e[4mHello World!\e[0m"
```

### Composition

Templates can include multiple format strings with distinct pipelines:

<!-- test_0dbfcd -->

```ruby
template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
Fmt(template, date: Time.now, msg: "this is cool")
#=> "Date: \e[35m2024-09-20\e[0m \e[1mThis Is Cool\e[0m"
```

#### Embedded Templates

Embedded templates can be nested within other templates:

<!-- test_efee7a -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold}}"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m"
```

Embeds can have their own pipelines:

<!-- test_abb7ea -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold}}|>underline"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1m\e[4mI'm embedded!\e[0m"
```

Embeds can be deeply nested:

<!-- test_79e924 -->

```ruby
template = "%{msg}|>faint {{%{embed}|>bold {{%{deep_embed}|>red|>bold}}}}"
Fmt(template, msg: "Look Ma...", embed: "I'm embedded!", deep_embed: "And I'm deeply embedded!")
#=> "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m \e[31m\e[1mAnd I'm deeply embedded!\e[0m"
```

Embeds can also span multiple lines:

<!-- test_054526 -->

```ruby
template = <<~T
  Multiline:
  %{one}|>red {{
    %{two}|>blue {{
      %{three}|>green
    }}
  }}|>bold
T
Fmt(template, one: "Red", two: "Blue", three: "Green")
#=> "Multiline:\n\e[31mRed\e[0m \e[1m\n  \e[34mBlue\e[0m \n    \e[32mGreen\e[0m"
```

### Customizing Fmt

Add custom filters by registering them with Fmt:

<!-- test_2cacce -->

```ruby
Fmt.register([Object, :shuffle]) { |*args, **kwargs| to_s.chars.shuffle.join }
Fmt("%s|>shuffle", "This don't make no sense.")
#=> "de.nnoTtsnh'oeek  ssim a "
```

Run a Ruby block with temporary filters without officially registering them:

<!-- test_7df4eb -->

```ruby
Fmt.with_overrides([Object, :red] => proc { |*args, **kwargs| Rainbow(self).crimson.bold }) do
  Fmt("%s|>red", "This is customized red!")
  #=> "\e[38;5;197m\e[1mThis is customized red!\e[0m"
end

Fmt("%s|>red", "This is original red!")
#=> "\e[31mThis is original red!\e[0m"
```

## Kernel Refinement

Fmt provides a kernel refinement that adds convenient methods for formatting and outputting text directly. To use these methods, you need to enable the refinement in your code:

```ruby
using Fmt::KernelRefinement
```

Once enabled, you'll have access to the following methods:

### `fmt(object, *pipeline)`

This method formats an object using a different pipeline syntax:

```ruby
fmt("Hello, World!", :bold) # => "\e[1mHello, World!\e[0m"
fmt(:hello, :underline) # => "\e[4mhello\e[0m"
fmt(Object.new, :red) # => "\e[31m#<Object:0x00007f9b8b0b0a08>\e[0m"
```

### `fmt_print(object, *pipeline)`

This method formats an object and prints it to STDOUT without a newline:

```ruby
fmt_print("Hello, World!", :italic) # Prints: "\e[3mHello, World!\e[0m"
fmt_print(:hello, :green) # Prints: "\e[32mhello\e[0m"
```

### `fmt_puts(object, *pipeline)`

This method formats an object and prints it to STDOUT with a newline:

```ruby
fmt_puts("Hello, World!", :bold, :underline) # Prints: "\e[1m\e[4mHello, World!\e[0m\n"
fmt_puts(:hello, :magenta) # Prints: "\e[35mhello\e[0m\n"
```

These methods provide a convenient way to use Fmt's formatting capabilities directly in your code without explicitly calling the `Fmt` method.

You can pass any number of macros when using these methods:

```ruby
fmt("Important!", :red, :bold, :underline)
# => "\e[31m\e[1m\e[4mImportant!\e[0m"

fmt_puts("Warning:", :yellow, :italic)
# Prints: "\e[33m\e[3mWarning:\e[0m\n"
```

These kernel methods make it easy to integrate Fmt's powerful formatting capabilities into your command-line interfaces or any part of your Ruby application where you need to format and output text.

## Performance

Fmt is optimized for performance:

- Tokenization: Uses StringScanner and Ripper to parse and tokenize templates
- Caching: Stores an Abstract Syntax Tree (AST) representation of each template, pipeline, and macro
- Speed: Current benchmarks show an average pipeline execution time of under 0.3 milliseconds

Complex pipelines may take slightly longer to execute.

## Sponsors

<p align="center">
  <em>Proudly sponsored by</em>
</p>
<p align="center">
  <a href="https://www.clickfunnels.com?utm_source=hopsoft&utm_medium=open-source&utm_campaign=fmt">
    <img src="https://images.clickfunnel.com/uploads/digital_asset/file/176632/clickfunnels-dark-logo.svg" width="575" />
  </a>
</p>
