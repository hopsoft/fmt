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

# Fmt: Your Friendly String Formatter

Welcome to Fmt, your go-to companion for Ruby string templating – simple, versatile, and surprisingly powerful!

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

- [What's Fmt, and why should you care?](#whats-fmt-and-why-should-you-care)
- [Getting Started: It's a Breeze!](#getting-started-its-a-breeze)
- [Usage: Your Formatting Adventure Begins](#usage-your-formatting-adventure-begins)
  - [Macros: The Secret Sauce](#macros-the-secret-sauce)
  - [Pipelines: Unleashing the Power of Chained Macros](#pipelines-unleashing-the-power-of-chained-macros)
  - [Supported Methods: The Ultimate Answer to Formatting](#supported-methods-the-ultimate-answer-to-formatting)
    - [Rainbow GEM: The Color of Magic](#rainbow-gem-the-color-of-magic)
  - [Composition: The Art of the Template](#composition-the-art-of-the-template)
    - [Embedded Templates: Nesting with Infinite Possibilities](#embedded-templates-nesting-with-infinite-possibilities)
  - [Customizing Fmt: Create Your Own Extensions](#customizing-fmt-create-your-own-extensions)
- [A Final Note](#a-final-note)
- [Sponsors: Our Awesome Supporters](#sponsors-our-awesome-supporters)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## What's Fmt, and why should you care?

Fmt is a template engine that harnesses the raw power of Ruby's native string formatting mechanics. It's like having a universal translator for your strings, turning your formatting wishes into beautiful, functional output.

- 🚀 Supercharge your general-purpose templating
- 🎨 Craft CLI applications so beautiful, they'll make even the most stoic developer smile
- 🧠 Intuitive enough for beginners, powerful enough for experts

## Getting Started: It's a Breeze!

First, let's get you set up. It's easier than making a cup of coffee!

```sh
bundle add rainbow # <- optional, but recommended for those who enjoy a splash of color
bundle add fmt
```

Then, in your Ruby file:

```ruby
require "rainbow" # <- optional, but why not add some color to your life?
require "fmt"
```

## Usage: Your Formatting Adventure Begins

Using Fmt is simpler than ordering takeout. Just create a string with Ruby's [format specifiers](https://ruby-doc.org/3.3.5/format_specifications_rdoc.html), much like you would for `sprintf`.

- `"%s"` - The classic
- `"%{variable}"` - For when you're feeling descriptive
- `"%<variable>s"` - When you want to be extra explicit

Remember, with Fmt, any string can be a template. It's like having a Swiss Army knife for text formatting!

### Macros: The Secret Sauce

Formatting macros are what make Fmt special. Append them to your format specifiers like so:

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

### Pipelines: Unleashing the Power of Chained Macros

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

### Supported Methods: The Ultimate Answer to Formatting

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

#### Rainbow GEM: The Color of Magic

Color and style support is available if your project includes the [Rainbow GEM](https://github.com/ku1ik/rainbow).

<!-- test_19c8ca -->

```ruby
template = "%{msg}|>cyan|>bold|>underline"
Fmt(template, msg: "Hello World!")
#=> "\e[36m\e[1m\e[4mHello World!\e[0m"
```

### Composition: The Art of the Template

You can mix and match macros that target any type within a pipeline.

Templates can also include multiple format strings with their own distinct pipelines.

<!-- test_0dbfcd -->

```ruby
template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
Fmt(template, date: Time.now, msg: "this is cool")
#=> "Date: \e[35m2024-09-20\e[0m \e[1mThis Is Cool\e[0m"
```

#### Embedded Templates: Nesting with Infinite Possibilities

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

### Customizing Fmt: Create Your Own Extensions

Want to add your own filters? It's easier than you might think:

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

## Performance: Fast Formatting

Fmt isn't just pretty – it's quick too!

- Tokenization: Uses StringScanner and Ripper to parse and tokenize templates
- Caching: Stores an Abstract Syntax Tree (AST) representation of each template, pipeline, and macro
- Speed: Current benchmarks show an average pipeline execution time of **under <0.3 milliseconds**

> [!NOTE]
> While Fmt is optimized for performance, remember that complex pipelines might take a tad longer.

## A Final Note

Remember, Fmt is here to make your life easier. While it might not solve all of life's mysteries, it certainly makes string formatting a breeze!

Happy formatting!

## Sponsors: Our Awesome Supporters

<p align="center">
  <em>Proudly sponsored by</em>
</p>
<p align="center">
  <a href="https://www.clickfunnels.com?utm_source=hopsoft&utm_medium=open-source&utm_campaign=fmt">
    <img src="https://images.clickfunnel.com/uploads/digital_asset/file/176632/clickfunnels-dark-logo.svg" width="575" />
  </a>
</p>
