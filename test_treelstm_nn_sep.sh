#!/bin/bash
base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

data_dir=$base_dir/misc_data
sent_dir=$base_dir/src/TreeLSTM_NN_sep
model_dir=$base_dir/models
pred_dir=$base_dir/sent_predictions_treelstm_nn_sep

i=10
echo 'Sentiment Classification: Restaurant'
#python $sent_dir/test_sent.py --aspects 12 --domain rest --cross-val-index 0 \
    #--model $model_dir/rest.treelstm_nn_sep.mlp_units_256_layers_3_relu.lr1.0e-04.dropout0.3.$i.json \
    #--weights $model_dir/rest.treelstm_nn_sep.mlp_units_256_layers_3_relu.lr1.0e-04.dropout0.3.${i}_final.hdf5 \
    #--output $pred_dir/rest.pol.pred.$i

echo 'Sentiment Classification: Laptop'
python $sent_dir/test_sent.py --aspects 81 --domain lapt --cross-val-index 0 \
    --model $model_dir/lapt.treelstm_nn_sep.mlp_units_256_layers_3_relu.lr1.0e-04.dropout0.3.$i.json \
    --weights $model_dir/lapt.treelstm_nn_sep.mlp_units_256_layers_3_relu.lr1.0e-04.dropout0.3.${i}_final.hdf5 \
    --output $pred_dir/lapt.pol.pred.$i
