RENAME TABLE `ROOT_DOMAIN_OBJECT` TO `BENNU`;

ALTER TABLE DOMAIN_ROOT change OID_ROOT_DOMAIN_OBJECT OID_BENNU bigint unsigned;

alter table `BENNU` add `OID_ROOT` bigint unsigned;
alter table `USER` add `USERNAME` text, add `PASSWORD` text, add `OID_BENNU` bigint unsigned, add index (OID_BENNU);

update BENNU set OID_ROOT = 1;

update FF$DOMAIN_CLASS_INFO set DOMAIN_CLASS_NAME = 'org.fenixedu.bennu.core.domain.Bennu' where DOMAIN_CLASS_NAME = 'net.sourceforge.fenixedu.domain.RootDomainObject';
update FF$DOMAIN_CLASS_INFO set DOMAIN_CLASS_NAME = 'org.fenixedu.bennu.core.domain.User' where DOMAIN_CLASS_NAME = 'net.sourceforge.fenixedu.domain.User';
update FF$DOMAIN_CLASS_INFO set DOMAIN_CLASS_NAME = 'org.fenixedu.bennu.user.management.UserLoginPeriod' where DOMAIN_CLASS_NAME = 'net.sourceforge.fenixedu.domain.LoginPeriod';

update USER set OID_BENNU = OID_ROOT_DOMAIN_OBJECT;
update USER set USERNAME = USER_U_ID;
update USER set USERNAME = '<unknown>' where USERNAME is null;

alter table `CONTENT` add `TYPE` text, add `OID_BENNU` bigint unsigned;
update CONTENT join META_DOMAIN_OBJECT on CONTENT.OID_META_DOMAIN_OBJECT = META_DOMAIN_OBJECT.OID set CONTENT.TYPE = META_DOMAIN_OBJECT.TYPE;
update CONTENT set OID_BENNU = (SELECT OID FROM BENNU) where TYPE is not null;

RENAME TABLE `LOGIN_PERIOD` TO `USER_LOGIN_PERIOD`;
ALTER TABLE `USER_LOGIN_PERIOD` ADD `OID_USER` bigint unsigned, add index (OID_USER);
update USER_LOGIN_PERIOD set OID_USER = (SELECT OID_USER from IDENTIFICATION where IDENTIFICATION.OID = OID_LOGIN);

-- Passo 2

DROP TABLE `GENERIC_FILE`;
RENAME TABLE `FILE` TO `GENERIC_FILE`;
ALTER TABLE `GENERIC_FILE` CHANGE `CONTENT` `CONTENT_FILE` longblob; /* blueprint files */
ALTER TABLE `GENERIC_FILE` CHANGE `SIZE` `SIZE` bigint(20) default NULL;
ALTER TABLE `GENERIC_FILE` CHANGE `UPLOAD_TIME` `CREATION_DATE` timestamp NULL default NULL;
ALTER TABLE `GENERIC_FILE` CHANGE `MIME_TYPE` `CONTENT_TYPE` text;
ALTER TABLE `GENERIC_FILE` CHANGE `DISPLAY_NAME` `DISPLAY_NAME` text;
ALTER TABLE `GENERIC_FILE` CHANGE `FILENAME` `FILENAME` text;
ALTER TABLE `GENERIC_FILE` ADD `CONTENT_KEY` text;

UPDATE GENERIC_FILE SET OID_STORAGE = (SELECT OID_D_SPACE_FILE_STORAGE FROM BENNU);
UPDATE GENERIC_FILE SET CONTENT_KEY = EXTERNAL_STORAGE_IDENTIFICATION;
