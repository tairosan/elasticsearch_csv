#!/bin/bash

RESTORE_FLG=true
DELETE_OLD_INDICES=true
USE_SLACK=true
SLACK_USER="Date Updater"

INDEX_JSON=mapping.json
HOST_NAME=localhost:9200
DATE='date --date 'yesterday' + '%Y%m%d''
S3_REPO_NAME=s3_repo
SNAPSHOT_NAME="snapshot_${DATE}"

STANBY_ALIAS=stanby_crawler
OLD_STANBY_INDEX='curl -s $HOST_NAME/_cat/aliases | grep ^$STANBY_ALIAS | awk '{ print $2 }' '
NEW_STANBY_INDEX=stanby_crawler_${DATE}

echo query: $QUERY
echo old_index: $OLD_STANBY_INDEX
echo new_index: $NEW_STANBY_INDEX

print_message() {
	msg = $1
	if [ x$USE_SLACK = "xtrue" ] ; then
	python python2slack.py "$SLACK_USER" "$msg"
	else
	echo $msg
	fi
}

print_message "start testdata job."

restore_func() {
	## restore new index snapshot from s3
	INDEX_NAME = ''
	RET = ''
	echo $RET | grep -i error > dev/null
	if [ $? = 0] ; then
		print_message "Failed to restore $S3_REPO_NAME/$SNAPSHOT_NAME"
		exit 1
	fi

	RET=red
	while [ x$RET != "xyellow" ] ; do
		RET='curl -s XGET $HOST_NAME/_cluster/health?pretty | grep status | sed 's/*//g' | sed 's/"status":"\status":"\(.*\)",/\1/' '
		echo $RET
		sleep 5
	done

	## apply replica size 0
	curl -s XPUT ${HOST_NAME}/${NEW_STANBY_INDEX}/_settings -d '{"index":{"number_of_replicas":0}}'

	print_message "Resore function done."
}

delete_old_indices(){
	curl -s -XPOST $HOST_NAME/_aliases -d
	'{
		"actions": [
			{
				"add": {
					"index": "'${NEW_STANBY_INDEX}'",
					"alias": "'${STANBY_ALIAS}'"
				},
				"remove": {
					"index": "'${OLD_STANBY_INDEX}'",
					"alias": "'${STANBY_ALIAS}'"
				}
			},
		]
	}'

	# delete old_working_index
	curl -s -XDELETE $HOST_NAME/$OLD_STANBY_INDEX

	print_message "Re-cover alias on new_stanby_crawler index."
}

if [ x${RESTORE_FLG} = "xtrue" ] ; then
	restore_func
fi

if [ x${DELETE_OLD_INDICES} = "xtrue"] ; then
	delete_old_indices
fi

print_message "All jobs were finished"

