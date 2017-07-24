CREATE TABLE [ITERATION4].[U-26-PAD_INDEX_ON/OFF_U] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  UNIQUE ([col3]) WITH (PAD_INDEX = ON)
)
ON [PRIMARY]
GO