CREATE TABLE [ITERATION4].[U-26-IGNORE_DUP_KEY ON/OFF_U] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  UNIQUE ([col3]) WITH (IGNORE_DUP_KEY = ON)
)
ON [PRIMARY]
GO