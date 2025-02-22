# WebSockets for Elm 0.19

[billstclair/elm-bluetooth](https://package.elm-lang.org/packages/billstclair/elm-bluetooth/latest) is a library for accessing the JavaScript Bluetooth Web API. It uses ports to do that.

## Using the Package

See `Main.elm` in the the [example/src](https://github.com/billstclair/elm-bluetooth/tree/master/example/src) directory for details. You need to include [example/site/js/elm-bluetooth.js](https://github.com/billstclair/elm-bluetooth/tree/master/example/site/js/elm-bluetooth.js) in your web site, and load and initialize it from your `index.html`, as done by [example/site/index.html](https://github.com/billstclair/elm-bluetooth/tree/master/example/site/index.html).

## Example

To build the example:

    cd .../elm-bluetooth/example
    bin/build
    
This compiles the example Elm code into `.../elm-bluetooth/example/site/elm.js`.

Then aim a web browser at `.../elm-bluetooth/example/site/index.html`

The example is live at [lisplog.org/elm-bluetooth](https://lisplog.org/elm-bluetooth/).
