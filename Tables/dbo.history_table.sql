CREATE TABLE [dbo].[history_table] (
  [pk] [bigint] IDENTITY,
  [objectname] [varchar](255) NULL,
  [username] [varchar](255) NULL,
  [hosname] [varchar](255) NULL,
  [appname] [varchar](255) NULL,
  [timecreate] [datetime] NULL DEFAULT (getdate()),
  PRIMARY KEY CLUSTERED ([pk])
)
ON [PRIMARY]
GO