all: format build

format:
    typstyle -l=120 -i .

build:
    typst compile ./paper.typ ./out.pdf

figures:
    rm -rf ./figures
    mkdir -p ./figures
    cp ../xai-shapley-cluster/figures/part_0/page-1.png ./figures/synthetic_00_train_data.png
