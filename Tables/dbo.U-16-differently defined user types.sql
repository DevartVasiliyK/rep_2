CREATE TABLE [dbo].[U-16-differently defined user types] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [dbo].[Uchar_2] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO