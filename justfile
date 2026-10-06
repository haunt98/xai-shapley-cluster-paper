all: format build

format:
    typstyle -l=120 -i .

build:
    typst compile ./paper.typ ./out.pdf

figures:
    rm -rf ./figures
    mkdir -p ./figures
    cp ../xai-shapley-cluster/figures/part_0/page-1.png ./figures/synthetic_00_train_data.png
    cp ../xai-shapley-cluster/figures/part_0/page-2.png ./figures/synthetic_01_predictions_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_0/page-3.png ./figures/synthetic_02_predictions.png
    cp ../xai-shapley-cluster/figures/part_1/page-2.png ./figures/synthetic_03_predictions_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_1/page-3.png ./figures/synthetic_04_predictions_knn10.png
    cp ../xai-shapley-cluster/figures/part_2/page-2.png ./figures/synthetic_05_squared_error_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_2/page-3.png ./figures/synthetic_06_squared_error.png
    cp ../xai-shapley-cluster/figures/part_3/page-2.png ./figures/synthetic_07_squared_error_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_3/page-3.png ./figures/synthetic_08_squared_error_knn10.png
    cp ../xai-shapley-cluster/figures/part_4/page-2.png ./figures/synthetic_09_classification_test_data_anomalies.png
    cp ../xai-shapley-cluster/figures/part_4/page-3.png ./figures/synthetic_10_classification_compare_train_aakr.png
    cp ../xai-shapley-cluster/figures/part_4/page-4.png ./figures/synthetic_11_classification_compare_test_aakr.png
    cp ../xai-shapley-cluster/figures/part_4/page-5.png ./figures/synthetic_12_classification_number_iterations.png
