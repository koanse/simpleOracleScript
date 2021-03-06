SET SERVEROUTPUT ON

CREATE TABLE AGEN
  (ANUM NUMBER(4) NOT NULL,
   ANAME VARCHAR2(60) NOT NULL,
   AYEAR NUMBER(4) NOT NULL,
   ACITY VARCHAR2(40) NOT NULL);

ALTER TABLE AGEN
   ADD (CONSTRAINT AGEN_PK_CNUM PRIMARY KEY (ANUM));

CREATE TABLE SERV
  (SNUM NUMBER(4) NOT NULL,
   SNAME VARCHAR2(50) NOT NULL,
   SCOST VARCHAR2(30) NOT NULL,
   ANUM NUMBER(4) NOT NULL);

ALTER TABLE SERV
   ADD (CONSTRAINT SERV_PK_SNUM PRIMARY KEY (SNUM));

ALTER TABLE SERV
ADD (CONSTRAINT SERV_FK_CNUM FOREIGN KEY (ANUM) REFERENCES AGEN (ANUM) ON DELETE CASCADE);

CREATE OR REPLACE VIEW AGEN_SERV
AS
  SELECT AGEN.ANUM,
    AGEN.ANAME,
    SERV.SNAME,
    SERV.SCOST
  FROM AGEN,
    SERV
  WHERE AGEN.ANUM = SERV.ANUM
  ORDER BY AGEN.ANUM;

CREATE SEQUENCE SQ_AGEN_NUM
 INCREMENT BY 1 
 START WITH 1001;

CREATE SEQUENCE SQ_SERV_NUM
 INCREMENT BY 1 
 START WITH 2001;

CREATE OR REPLACE TRIGGER TR_DEL_AGEN
  BEFORE DELETE ON AGEN
BEGIN
  IF TO_NUMBER(TO_CHAR(SYSDATE, 'DD')) > 25 THEN
    RAISE_APPLICATION_ERROR(-20001, '�������� ����� 25-�� ����� ���������.');
  END IF;
END;

CREATE OR REPLACE PACKAGE REAL_ESTATE_AGEN AS
  PROCEDURE INSERT_AGEN_SERV; -- ��������� ������� AGEN � SERV
  PROCEDURE DELETE_AGEN_SERV; -- ������� ��� ������ �� AGEN � SERV
  PROCEDURE DELETE_NAMED_AGEN (AGEN_NAME IN VARCHAR2); -- ������� ��������� � ��������� ���������
  PROCEDURE INFO_AGEN (VCOST IN NUMBER); -- ����� ���������� �� ���������� � �� �������, ���������� ����� �������� 
END;

CREATE OR REPLACE PACKAGE BODY REAL_ESTATE_AGEN
AS
  PROCEDURE INSERT_AGEN_SERV
  IS
    TMPID NUMBER;
  BEGIN
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT INTO AGEN VALUES
      (TMPID, '�������', 2015, '�����������'
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '�������/�������',
        20000,
        TMPID
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '�����', 10000, TMPID
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '������� ���������',
        16000,
        TMPID
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '������', 5000, TMPID
      );
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT INTO AGEN VALUES
      (TMPID, '����� �', 2016, '�����������'
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '�������/�������',
        30000,
        TMPID
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '�����', 20000, TMPID
      );
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT INTO AGEN VALUES
      (TMPID, '��������', 2017, '�����������'
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '������', 15000, TMPID
      );
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT
    INTO AGEN VALUES
      (
        TMPID,
        '����������� ��',
        2014,
        '�����������'
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '������', 45000, 1004
      );
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT INTO AGEN VALUES
      (TMPID, '�����', 2013, '�����������'
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '�������/�������',
        40000,
        TMPID
      );
    INSERT INTO SERV VALUES
      (SQ_SERV_NUM.NEXTVAL, '�����', 15000, TMPID
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '������� ���������',
        17000,
        TMPID
      );
    TMPID := SQ_AGEN_NUM.NEXTVAL;
    INSERT INTO AGEN VALUES
      (TMPID, '������� ������', 2013, '�����������'
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '������� ���������',
        18000,
        TMPID
      );
    INSERT
    INTO SERV VALUES
      (
        SQ_SERV_NUM.NEXTVAL,
        '������� ���������',
        19000,
        TMPID
      );
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('������ ���������� ������');
    ROLLBACK;
  END;
  PROCEDURE DELETE_AGEN_SERV
  IS
  BEGIN
    DELETE FROM SERV;
    DELETE FROM AGEN;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('������ ������� ������');
    ROLLBACK;
  END;
  PROCEDURE DELETE_NAMED_AGEN(
      AGEN_NAME IN VARCHAR2)
  IS
    VNUM NUMBER;
  BEGIN
    SELECT COUNT(*) INTO VNUM FROM AGEN WHERE ANAME = AGEN_NAME;
    IF (VNUM > 0) THEN
      DELETE FROM AGEN WHERE ANAME = AGEN_NAME;
    ELSE
      DBMS_OUTPUT.PUT_LINE('��������� �� �������');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('������ ������ ���������');
  END;
  PROCEDURE INFO_AGEN(
      VCOST IN NUMBER)
  IS
    CURSOR K_INFO
    IS
      SELECT * FROM AGEN_SERV WHERE SCOST < VCOST;
    VNUM AGEN_SERV.ANUM    %TYPE;
    VANAME AGEN_SERV.ANAME %TYPE;
    VSNAME AGEN_SERV.SNAME %TYPE;
    VSCOST AGEN_SERV.SCOST %TYPE;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('���������� �� ����������, ��������� ����� ������� ������ '|| VCOST);
    OPEN K_INFO;
    LOOP
      FETCH K_INFO INTO VNUM, VANAME, VSNAME, VSCOST;
      EXIT
    WHEN (K_INFO %NOTFOUND);
      DBMS_OUTPUT.PUT_LINE('�����: '||VNUM||', ��������: '||VANAME||', ������: '|| VSNAME || ', ���������: '|| VSCOST);
    END LOOP;
    IF (K_INFO %ROWCOUNT = 0) THEN
      DBMS_OUTPUT.PUT_LINE('������ �� �������');
    END IF;
    CLOSE K_INFO;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('������ ��������� ���������� �� ����������');
  END;
END;