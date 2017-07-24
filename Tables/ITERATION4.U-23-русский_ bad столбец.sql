SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-23-русский/ bad столбец] (
  [столбец1] [int] NOT NULL,
  [~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/] [int] NULL,
  [col3] [int] NULL,
  [компъютыд_сталбец1] AS ([столбец1]*[~[]]]]]][[`!@#$%^&*(_'')-''''''+=|\?.,><""/]) PERSISTED NOT NULL,
  PRIMARY KEY CLUSTERED ([столбец1]),
  CHECK ([компъютыд_сталбец1] IS NOT NULL)
)
ON [PRIMARY]
GO