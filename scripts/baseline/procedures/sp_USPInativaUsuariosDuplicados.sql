-- ============================================================
-- BASELINE: dbo.sp_USPInativaUsuariosDuplicados
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_USPInativaUsuariosDuplicados]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[sp_USPInativaUsuariosDuplicados] as 

update  tb_usuario
set usr_in_ativo = 0
where usr_cd_usuario in (
    select distinct 
        usr_cd_usuario
    from (
            select
            ROW_NUMBER() OVER (partition by usr_nm_usuario ORDER BY usr_cd_usuario desc) as row_number
            ,cli_cd_codigo_cliente as cli
            ,* 
            from tb_usuario
            where 1=1
            and usr_in_ativo = 1
    ) as a
    where row_number > 1
)

GO
