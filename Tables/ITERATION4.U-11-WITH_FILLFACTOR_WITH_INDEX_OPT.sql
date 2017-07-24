CREATE TABLE [ITERATION4].[U-11-WITH_FILLFACTOR_WITH_INDEX_OPT] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) WITH (FILLFACTOR = 1)
)
ON [PRIMARY]
GO