all: format build

format:
    typstyle -l=120 -i .

build:
    typst compile ./paper.typ ./out.pdf
