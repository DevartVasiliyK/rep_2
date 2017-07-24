CREATE TABLE [ITERATION4].[U-11-IGNORE_DUP_KEY_ON_IGNORE_DUP_KEY_OFF] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  [col6] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]) WITH (IGNORE_DUP_KEY = ON)
)
ON [PRIMARY]
GO