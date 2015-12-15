--[[

  Tree-LSTM training script for sentiment classication on the Stanford
  Sentiment Treebank

--]]

require('..')

function accuracy(pred, gold)
  return torch.eq(pred, gold):sum() / pred:size(1)
end

-- read command line arguments
local args = lapp [[
Testing script for sentiment classification on the SST dataset.
  -t,--dataset (default restaurant)  Datasets: [restaurant, laptop]
  <model> (string) Model path
]]
print(args.model)

local model_class = treelstm.TreeLSTMSentiment

-- binary or fine-grained subtask
local fine_grained = not args.binary

-- directory containing dataset files
local data_dir
if args.dataset == 'restaurant' then
  data_dir = 'data/absa_restaurant/'
elseif args.dataset == 'laptop' then
  data_dir = 'data/absa_laptop/'
end

-- load vocab
local vocab = treelstm.Vocab(data_dir .. 'vocab-cased.txt')

-- load embeddings
print('loading word embeddings')
local emb_dir = 'data/glove/'
local emb_prefix = emb_dir .. 'glove.840B'
local emb_vocab, emb_vecs = treelstm.read_embedding(emb_prefix .. '.vocab', emb_prefix .. '.300d.th')
local emb_dim = emb_vecs:size(2)

-- use only vectors in vocabulary (not necessary, but gives faster training)
local num_unk = 0
local vecs = torch.Tensor(vocab.size, emb_dim)
for i = 1, vocab.size do
  local w = string.gsub(vocab:token(i), '\\', '') -- remove escape characters
  if emb_vocab:contains(w) then
    vecs[i] = emb_vecs[emb_vocab:index(w)]
  else
    num_unk = num_unk + 1
    vecs[i]:uniform(-0.05, 0.05)
  end
end
print('unk count = ' .. num_unk)
emb_vocab = nil
emb_vecs = nil
collectgarbage()

-- load datasets
print('loading datasets')
local train_dir = data_dir .. 'train/'
local dev_dir = data_dir .. 'dev/'
--local test_dir = data_dir .. 'test/'
local dependency = true
local train_dataset = treelstm.read_sentiment_dataset(train_dir, vocab, fine_grained, dependency)
local dev_dataset = treelstm.read_sentiment_dataset(dev_dir, vocab, fine_grained, dependency)
--local test_dataset = treelstm.read_sentiment_dataset(test_dir, vocab, fine_grained, dependency)

printf('num train = %d\n', train_dataset.size)
printf('num dev   = %d\n', dev_dataset.size)
--printf('num test  = %d\n', test_dataset.size)

-- load model
local model = model_class.load(args.model)

-- print information
header('model configuration')
model:print_config()

local train_features = model:get_features(train_dataset)
local dev_features = model:get_features(dev_dataset)
--print(dev_features)

-- create predictions and models directories if necessary
--[
if lfs.attributes(treelstm.predictions_dir) == nil then
  lfs.mkdir(treelstm.predictions_dir)
end
--]]

local train_features_save_path = string.format(treelstm.predictions_dir .. '/%s_train.feat', args.dataset)
local dev_features_save_path = string.format(treelstm.predictions_dir .. '/%s_dev.feat', args.dataset)

-- save features to disk
print('writing features...')
local train_features_file = torch.DiskFile(train_features_save_path, 'w')
train_features_file:noAutoSpacing()
for i = 1, train_features:size(1) do
	train_features_file:writeDouble(train_features[i][1])
	for j = 2, train_features:size(2) do
		train_features_file:writeString(' ')
		train_features_file:writeDouble(train_features[i][j])
	end
	train_features_file:writeString('\n')
end
train_features_file:close()

local dev_features_file = torch.DiskFile(dev_features_save_path, 'w')
dev_features_file:noAutoSpacing()
for i = 1, dev_features:size(1) do
	dev_features_file:writeDouble(dev_features[i][1])
	for j = 2, dev_features:size(2) do
		dev_features_file:writeString(' ')
		dev_features_file:writeDouble(dev_features[i][j])
	end
	dev_features_file:writeString('\n')
end
dev_features_file:close()
