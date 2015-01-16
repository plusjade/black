## Black

Black parses diff output from `diff` and `git diff` and provides an enumerable ruby interface for lines and metadata.

Black uses this diff interface to render a syntax-highlighted diff view in HTML.

## Status

Black isn't documented yet.

I'm getting this out for those who are compfortable diving into the source and getting some initial value from it.

Consider this a work in progress.

## Usage

```ruby
diff = Black::Diff.new('older string', 'newer string', 'file-name.html')
output = Black::HTMLView.render(diff: diff)
```

The filename determines how the content will be highlighted.

The output is HTML only. To output the css:

```ruby
css = Black::Stylesheets.css({ style: :compressed })
```

Black uses sass, so all options are passed right into sass options. Have a look at `Black::Stylesheets` for more info.

## Version

**0.0.1** - Please consider the API alpha and unstable.

Black adheres to [Semantic Versioning](http://semver.org/)

## Dependencies

1. [rouge](https://github.com/jneen/rouge) for syntax highlighting
1. [sass](http://sass-lang.com/) for stylesheet management


## Rubies

Tested with ruby 1.9.3+

ruby 1.8.x not supported

## Platforms

This only supports unix-based systems at the moment.

But the shell execution is wrapped like so:

```ruby
# Black::Diff.execute()
def self.execute(*command_args)
  `diff #{ command_args.join(' ') }`
end
```

So you can reimplement this method to suit your own platform needs:
```ruby
class Black::Diff
  def self.execute(*command_args)
    # do some custom stuff
  end
end
```

## License 

[MIT](http://www.opensource.org/licenses/mit-license.html)
