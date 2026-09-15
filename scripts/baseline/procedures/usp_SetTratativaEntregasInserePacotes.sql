-- ============================================================
-- BASELINE: dbo.usp_SetTratativaEntregasInserePacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_SetTratativaEntregasInserePacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_SetTratativaEntregasInserePacotes] (@idpacote bigint )
AS
BEGIN
insert into tb_tratativas_entregas_inclusas values (@idpacote)
delete from tb_tratativas_entregas_inclusas where idpacote is null
END
GO
