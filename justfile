all: format build

format:
    typstyle -l=120 -i .

build:
    typst compile --root .. ./paper.typ ./out.pdf

watch:
    typst watch --root .. ./paper.typ ./out.pdf

figures:
    rm -rf ./figures
    mkdir -p ./figures
    cp ../xai-shapley-cluster/figures/part_0/page-1.png ./figures/synthetic_00_train_data.png
    cp ../xai-shapley-cluster/figures/part_0/page-2.png ./figures/synthetic_01_predictions_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_0/page-3.png ./figures/synthetic_02_predictions_selected.png
    cp ../xai-shapley-cluster/figures/part_1/page-2.png ./figures/synthetic_03_predictions_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_1/page-3.png ./figures/synthetic_04_predictions_selected_knn10.png
    cp ../xai-shapley-cluster/figures/part_2/page-2.png ./figures/synthetic_05_squared_error_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_2/page-3.png ./figures/synthetic_06_squared_error_selected.png
    cp ../xai-shapley-cluster/figures/part_3/page-2.png ./figures/synthetic_07_squared_error_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_3/page-3.png ./figures/synthetic_08_squared_error_selected_knn10.png
    cp ../xai-shapley-cluster/figures/part_4/page-2.png ./figures/synthetic_09_classification_test_data_anomalies.png
    cp ../xai-shapley-cluster/figures/part_4/page-3.png ./figures/synthetic_10_classification_compare_train_aakr.png
    cp ../xai-shapley-cluster/figures/part_4/page-4.png ./figures/synthetic_11_classification_compare_test_aakr.png
    cp ../xai-shapley-cluster/figures/part_4/page-5.png ./figures/synthetic_12_classification_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_5/page-01.png ./figures/bikeshare_00_train_data_bikes_hr_holiday.png
    cp ../xai-shapley-cluster/figures/part_5/page-02.png ./figures/bikeshare_01_train_data_weekday_workingday_weathersit.png
    cp ../xai-shapley-cluster/figures/part_5/page-03.png ./figures/bikeshare_02_train_data_temp_hum_windspeed.png
    cp ../xai-shapley-cluster/figures/part_5/page-04.png ./figures/bikeshare_03_test_data_bikes_hr_holiday.png
    cp ../xai-shapley-cluster/figures/part_5/page-05.png ./figures/bikeshare_04_test_data_weekday_workingday_weathersit.png
    cp ../xai-shapley-cluster/figures/part_5/page-06.png ./figures/bikeshare_05_test_data_temp_hum_windspeed.png
    cp ../xai-shapley-cluster/figures/part_5/page-07.png ./figures/bikeshare_06_eval_data_bikes_hr_holiday.png
    cp ../xai-shapley-cluster/figures/part_5/page-08.png ./figures/bikeshare_07_eval_data_weekday_workingday_weathersit.png
    cp ../xai-shapley-cluster/figures/part_5/page-09.png ./figures/bikeshare_08_eval_data_temp_hum_windspeed.png
    cp ../xai-shapley-cluster/figures/part_5/page-10.png ./figures/bikeshare_09_predictions_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_5/page-11.png ./figures/bikeshare_10_predictions_selected.png
    cp ../xai-shapley-cluster/figures/part_5/page-12.png ./figures/bikeshare_11_predictions_strategy_mse.png
    cp ../xai-shapley-cluster/figures/part_6/page-10.png ./figures/bikeshare_12_squared_error_number_iterations.png
    cp ../xai-shapley-cluster/figures/part_6/page-11.png ./figures/bikeshare_13_squared_error_selected.png
    cp ../xai-shapley-cluster/figures/part_6/page-12.png ./figures/bikeshare_14_squared_error_strategy_mse.png
    cp ../xai-shapley-cluster/figures/part_7/page-10.png ./figures/bikeshare_15_predictions_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_7/page-11.png ./figures/bikeshare_16_predictions_selected_knn10.png
    cp ../xai-shapley-cluster/figures/part_7/page-12.png ./figures/bikeshare_17_predictions_strategy_mse_knn10.png
    cp ../xai-shapley-cluster/figures/part_8/page-10.png ./figures/bikeshare_18_squared_error_number_iterations_knn10.png
    cp ../xai-shapley-cluster/figures/part_8/page-11.png ./figures/bikeshare_19_squared_error_selected_knn10.png
    cp ../xai-shapley-cluster/figures/part_8/page-12.png ./figures/bikeshare_20_squared_error_strategy_mse_knn10.png

results:
    rm -rf ./results
    mkdir -p ./results
    cp ../xai-shapley-cluster/results/part_0/phi_global.csv ./results/synthetic_00_predictions_phi_global.csv
    cp ../xai-shapley-cluster/results/part_0/phi_selected.csv ./results/synthetic_01_predictions_phi_selected.csv
    cp ../xai-shapley-cluster/results/part_0/mse_full.csv ./results/synthetic_02_predictions_mse_full.csv
    cp ../xai-shapley-cluster/results/part_1/phi_global.csv ./results/synthetic_03_predictions_phi_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_1/phi_selected.csv ./results/synthetic_04_predictions_phi_selected_knn10.csv
    cp ../xai-shapley-cluster/results/part_1/mse_full.csv ./results/synthetic_05_predictions_mse_full_knn10.csv
    cp ../xai-shapley-cluster/results/part_2/phi_global.csv ./results/synthetic_06_squared_error_phi_global.csv
    cp ../xai-shapley-cluster/results/part_2/phi_selected.csv ./results/synthetic_07_squared_error_phi_selected.csv
    cp ../xai-shapley-cluster/results/part_2/mse_full.csv ./results/synthetic_08_squared_error_mse_full.csv
    cp ../xai-shapley-cluster/results/part_3/phi_global.csv ./results/synthetic_09_squared_error_phi_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_3/phi_selected.csv ./results/synthetic_10_squared_error_phi_selected_knn10.csv
    cp ../xai-shapley-cluster/results/part_3/mse_full.csv ./results/synthetic_11_squared_error_mse_full_knn10.csv
    cp ../xai-shapley-cluster/results/part_4/phi_global.csv ./results/synthetic_12_classification_phi_global.csv
    cp ../xai-shapley-cluster/results/part_4/mse_full.csv ./results/synthetic_13_classification_mse_full.csv
    cp ../xai-shapley-cluster/results/part_5/phi_global.csv ./results/bikeshare_00_predictions_phi_global.csv
    cp ../xai-shapley-cluster/results/part_5/phi_selected.csv ./results/bikeshare_01_predictions_phi_selected.csv
    cp ../xai-shapley-cluster/results/part_5/mse_full.csv ./results/bikeshare_02_predictions_mse_full.csv
    cp ../xai-shapley-cluster/results/part_5/mse_global.csv ./results/bikeshare_03_predictions_mse_global.csv
    cp ../xai-shapley-cluster/results/part_5/mse_per_cluster.csv ./results/bikeshare_04_predictions_mse_per_cluster.csv
    cp ../xai-shapley-cluster/results/part_5/strategy_allocation.csv ./results/bikeshare_05_predictions_strategy_allocation.csv
    cp ../xai-shapley-cluster/results/part_6/phi_global.csv ./results/bikeshare_06_squared_error_phi_global.csv
    cp ../xai-shapley-cluster/results/part_6/phi_selected.csv ./results/bikeshare_07_squared_error_phi_selected.csv
    cp ../xai-shapley-cluster/results/part_6/mse_full.csv ./results/bikeshare_08_squared_error_mse_full.csv
    cp ../xai-shapley-cluster/results/part_6/mse_global.csv ./results/bikeshare_09_squared_error_mse_global.csv
    cp ../xai-shapley-cluster/results/part_6/mse_per_cluster.csv ./results/bikeshare_10_squared_error_mse_per_cluster.csv
    cp ../xai-shapley-cluster/results/part_6/strategy_allocation.csv ./results/bikeshare_11_squared_error_strategy_allocation.csv
    cp ../xai-shapley-cluster/results/part_7/phi_global.csv ./results/bikeshare_12_predictions_phi_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_7/phi_selected.csv ./results/bikeshare_13_predictions_phi_selected_knn10.csv
    cp ../xai-shapley-cluster/results/part_7/mse_full.csv ./results/bikeshare_14_predictions_mse_full_knn10.csv
    cp ../xai-shapley-cluster/results/part_7/mse_global.csv ./results/bikeshare_15_predictions_mse_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_7/mse_per_cluster.csv ./results/bikeshare_16_predictions_mse_per_cluster_knn10.csv
    cp ../xai-shapley-cluster/results/part_7/strategy_allocation.csv ./results/bikeshare_17_predictions_strategy_allocation_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/phi_global.csv ./results/bikeshare_18_squared_error_phi_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/phi_selected.csv ./results/bikeshare_19_squared_error_phi_selected_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/mse_full.csv ./results/bikeshare_20_squared_error_mse_full_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/mse_global.csv ./results/bikeshare_21_squared_error_mse_global_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/mse_per_cluster.csv ./results/bikeshare_22_squared_error_mse_per_cluster_knn10.csv
    cp ../xai-shapley-cluster/results/part_8/strategy_allocation.csv ./results/bikeshare_23_squared_error_strategy_allocation_knn10.csv
