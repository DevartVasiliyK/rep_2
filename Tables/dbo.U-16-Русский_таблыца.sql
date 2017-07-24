CREATE TABLE [dbo].[U-16-Русский_таблыца] (
  [русский_сталбЭц1] [int] NOT NULL,
  [col2] [int] NULL,
  [русский_сталбЭц3] [int] NULL,
  PRIMARY KEY CLUSTERED ([русский_сталбЭц1]),
  CHECK ([U-16-Русский_таблыца].[русский_сталбЭц3] IS NOT NULL)
)
ON [PRIMARY]
GO