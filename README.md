# docker-go2go

This docker image contains prebuilt set of [go2go](https://blog.golang.org/generics-next-step) utils with aim to test and run your early go2 applications. The image serves as a nightly build of go's [dev.go2go](https://go.googlesource.com/go/+/refs/heads/dev.go2go/README.go2go.md) branch containing the implementation of the [generics draft](https://go.googlesource.com/proposal/+/refs/heads/master/design/go2draft-type-parameters.md), specifically.

## How to use the image?

You can you `go2` utility to build, test and run you go2 files like this:

```sh
go2 run main.go2
```

The other option is to use this image as base of your own, like the following:

```dockerfile
FROM modern-dev/go2go:latest

WORKDIR /go/src
COPY ./src /go/src

CMD ["go2 run main.go2"]
```

You may also want to pass the source folder in and run the container directly like so:

```sh
docker run --rm -it --name test-go2go -v "$PWD":/go/src -w /go/src modern-dev/go2go:latest go2 run main.go2
```

## The `dev.go2go` branch

This branch contains a type checker and a translation tool for experimentation with generics in Go. This implements the [generics design draft](https://go.googlesource.com/proposal/+/refs/heads/master/design/go2draft-type-parameters.md).

You can build this branch [as usual](https://golang.org/doc/install/source). You can then use the new go2go tool. Write your generic code in a file with the extension .go2 instead of .go. Run it using go tool go2go run x.go2. There are some sample packages in cmd/go2go/testdata/go2path/src. You can see the full documentation for the tool by running go doc cmd/go2go.

The go2go tool will look for .go2 files using the environment variable GO2PATH. You can find some useful packages that you might want to experiment with by setting GO2PATH=$GOROOT/src/cmd/go2go/testdata/go2path.

If you find bugs in the updated type checker or in the translation tool, they should be filed in the [standard Go issue tracker](https://golang.org/issue). Please start the issue title with cmd/go2go. Note that the issue tracker should only be used for reporting bugs in the tools, not for discussion of changes to the language.

Unlike typical dev branches, we do not intend any eventual merge of this code into the master branch. We will update it for bug fixes and change to the generic design draft. If a generics language proposal is accepted, it will be implemented in the standard compiler, not via a translation tool. The necessary changes to the go/* packages (go/ast, go/parser, and so forth) may re-use code from this prototype but will follow the usual code review process.

## :green_book: License

Copyright (c) 2020 Bohdan Shtepan

---

> [modern-dev.com](http://modern-dev.com) &nbsp;&middot;&nbsp;
> GitHub [@virtyaluk](https://github.com/virtyaluk) &nbsp;&middot;&nbsp;
> Twitter [@virtyaluk](https://twitter.com/virtyaluk)
