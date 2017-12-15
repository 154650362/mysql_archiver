create view vw_db_archive_report_weekly as
-- ����ǰһ�ܵ����ݿ�鵵���
select  concat(year(min(archive_start)),week(min(archive_start))) archive_week, -- �鵵�ܴ�
				date_format(min(archive_start),'%Y-%m-%d') archive_week_start, -- �鵵ʱ����
				date_format(max(archive_start),'%Y-%m-%d') archive_week_end, -- �鵵ʱ��ֹ
				server_source, -- ������ip/����
				db_source, -- ���ݿ�schema
				table_source, -- ����
			 ifnull(sum(case archive_status when 'Y' then 1 end),0) archive_success_qty, -- �鵵�ɹ�����
		   ifnull(sum(case archive_status when 'N' then 1 end),0) archive_fail_qty, -- �鵵ʧ������
			 ifnull(sum(case archive_status when 'Y' then archive_qty end),0) archive_sum_data, -- �ܹ鵵������
			 ifnull(round(sum(case archive_status when 'Y' then timestampdiff(SECOND, archive_start, archive_end) end)/60,2),0) archive_sum_minute, -- �ܹ鵵ʱ��
			 ifnull(round(sum(case archive_status when 'Y' then archive_qty end) / sum(case archive_status when 'Y' then 1 end),0),0) archive_avg_data, -- ƽ���鵵������(�鵵������/�鵵�ɹ�����)
			 ifnull(round(ifnull(round(sum(case archive_status when 'Y' then timestampdiff(SECOND, archive_start, archive_end) end)/60,2),0) 
       / ifnull(sum(case archive_status when 'Y' then 1 end),0),2),0) archive_avg_minute -- ƽ���鵵ʱ��(�ܹ鵵ʱ��/�鵵�ɹ�����)
  from db_archive_log
  where week(archive_start) = week(date_add(curdate(), interval - 7 day))
  group by server_source, db_source, table_source 