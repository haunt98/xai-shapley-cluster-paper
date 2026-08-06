all: format build

format:
    typstyle -i .

build:
    typst compile ./paper.typ ./paper.pdf

watch:
    typst watch ./paper.typ ./paper.pdf
