function cfg = single()
cfg = simstudy.config.base();        % 既存の共通設定をロード
cfg.sampleSize  = 30;                % N
cfg.repetitions = 1000;              % rep
cfg.genModel    = "gumbel";          % 真の分布 (GEV with k=0)
cfg.fitModels   = ["gev"];           % 推定モデル
cfg.metrics     = ["SLSC"];          % 評価指標
end