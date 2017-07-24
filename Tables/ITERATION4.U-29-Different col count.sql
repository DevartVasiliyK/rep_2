CREATE TABLE [ITERATION4].[U-29-Different col count] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-29-Different col count]
  ADD CONSTRAINT [рисский_констр] FOREIGN KEY ([col3], [col4]) REFERENCES [ITERATION4].[U-29-Different PK count] ([col1], [col2])
GO