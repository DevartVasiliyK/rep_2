CREATE TABLE [dbo].[P-2-_timestamp_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_timestamp_decimal(5,3)] [timestamp],
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO