SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-24-ХворинГ кей на руский сталабцы] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [рус_стлб] AS ([col2]+[col3]) PERSISTED,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-24-ХворинГ кей на руский сталабцы]
  ADD FOREIGN KEY ([рус_стлб]) REFERENCES [ITERATION4].[U-24-бэд руский талица _~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] ([сталабэц_~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/1])
GO