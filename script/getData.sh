#!/bin/sh

WORK_DIR=/home/sora/work/asinfo
TMP_DIR=${WORK_DIR}/tmp
SCRIPT_DIR=${WORK_DIR}/script

WGET_CMD=/usr/local/bin/wget
NKF_CMD=/usr/local/bin/nkf
PERL_CMD=/usr/local/bin/perl

rm -f ${TMP_DIR}/*

${WGET_CMD} -P ${TMP_DIR} http://www.cidr-report.org/as2.0/autnums.html
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.arin.net/pub/stats/arin/delegated-arin-latest
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.apnic.net/pub/stats/iana/delegated-iana-latest
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.apnic.net/pub/stats/apnic/delegated-apnic-latest
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest
${WGET_CMD} -P ${TMP_DIR} ftp://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest
${WGET_CMD} -P ${TMP_DIR} http://www.nic.ad.jp/ja/ip/as-numbers.txt

for i in ${TMP_DIR}/*; do
	${NKF_CMD} -w --overwrite $i;
done

${PERL_CMD} ${SCRIPT_DIR}/build_asinfo.pl
