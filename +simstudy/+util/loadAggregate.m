function out = loadAggregate(root, query, varName)
%LOADAGGREGATE  Load aggregate.mat files under tag folders.
%
%   out = simstudy.util.loadAggregate(root, query)
%   out = simstudy.util.loadAggregate(root, query, varName)
%
%   root     : ルートフォルダ（例 "results"）
%   query    : (1) タグ名をそのまま指定   "N50_gumbel2gev"
%              (2) タグ名にマッチする正規表現  "^N\d+_gumbel2.*$"
%   varName  : aggregate.mat に保存されている変数名
%              （既定 = "allMetrics"）
%
%   戻り値 out は struct 配列
%       .tag      - ディレクトリ名タグ
%       .N        - サンプルサイズ
%       .gen      - 生成モデル
%       .fit      - フィットモデル
%       .file     - aggregate.mat のフルパス
%       .data     - 読み込んだ変数内容 (allMetrics 等)
%
%   %   例:
%   root = "results";
%   
%   % 1) タグ名を直接指定
%   S = simstudy.util.loadAggregate(root,"N50_gumbel2gev");
%   meanSLSC = mean(S.data.slsc);
%   
%   % 2) 正規表現で gumbel 生成すべて
%   S = simstudy.util.loadAggregate(root,"^N\d+_gumbel2.*$");
%   scatter([S.N], cellfun(@(m)mean(m.slsc), {S.data}));
%   xlabel('N'); ylabel('mean SLSC');
%

arguments
    root    string
    query   string
    varName string = "allMetrics"
end

% ------------------- 検索 ---------------------------------------------
tags = dir(root);
tags = tags([tags.isdir]);
tags = tags(~ismember({tags.name},{'.','..'}));

if endsWith(query,".mat") || contains(query,filesep)
    error("query must be tag name or reg. expression（not aggregate.mat）");
end

% フィルタ
if any(regexp(query,'[^A-Za-z0-9\^\*\+\.\?\(\)\[\]\|\\]')) % ざっくり正規表現チェック
    tagNames = {tags.name};
    use = ~cellfun(@isempty, regexp(tagNames, query,'once'));
    tags = tags(use);
else                           % 具体的なタグ名
    tags = tags(strcmp({tags.name}, query));
end

if isempty(tags)
    error("loadAggregate:NotFound","No tag matched '%s' under %s.", query, root);
end

% ------------------- 読み込み ------------------------------------------
pat = 'N(\d+)_([^0-9]+)2(.+)';   % タグ解析用

out(1:numel(tags)) = struct();
for i = 1:numel(tags)
    tag   = tags(i).name;
    agg   = fullfile(root, tag, "aggregate.mat");
    if ~isfile(agg)
        warning("%s is not found, skipped.", agg);
        continue
    end

    tok = regexp(tag, pat, 'tokens','once');
    out(i).tag  = tag;
    out(i).file = agg;

    if ~isempty(tok)
        out(i).N   = str2double(tok{1});
        out(i).gen = string(tok{2});
        out(i).fit = string(tok{3});
    else
        out(i).N   = NaN; out(i).gen=""; out(i).fit="";
    end

    tmp = load(agg, varName);
    if isfield(tmp, varName)
        out(i).data = tmp.(varName);
    else
        warning("%s doesn't have the variable '%s'.", agg, varName);
        out(i).data = [];
    end
end
end