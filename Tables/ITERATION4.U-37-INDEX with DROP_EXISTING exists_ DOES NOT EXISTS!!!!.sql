CREATE TABLE [ITERATION4].[U-37-INDEX with DROP_EXISTING exists/ DOES NOT EXISTS!!!!] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

CREATE INDEX [U-37-INDEX with DROP_EXISTING exists/ DOES NOT EXISTS!!!!]
  ON [ITERATION4].[U-37-INDEX with DROP_EXISTING exists/ DOES NOT EXISTS!!!!] ([col2])
  INCLUDE ([col3])
  ON [PRIMARY]
GO