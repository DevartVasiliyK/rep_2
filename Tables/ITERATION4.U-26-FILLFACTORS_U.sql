CREATE TABLE [ITERATION4].[U-26-FILLFACTORS_U] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  UNIQUE ([col3]) WITH (FILLFACTOR = 1)
)
ON [PRIMARY]
GO