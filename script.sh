#!/bin/bash
Help()
{
           echo "Script increments volumes of instance specified by it's Name tag value. Increment size is specified inside the script as well."
   echo "By default, script implements "
echo
echo "Syntax: script.sh [-n|i|a|h]"
echo "options:"
echo "n     Target instance Name tag value."
echo "i     Planned size increment for target instance's volumes."
echo "a     Increment size only for the volumes tied to specified instance (the ones that have Delete On Termination flag on and will be deleted with this instance's deletion)."
echo "h     Print Help."
echo
}



volumeflag=0
while getopts ahn:i: flag
        do
        case "${flag}" in
                n) nameTag=$OPTARG ;;
                i) requestedIncrement=$OPTARG ;;
                a) #run volume size increment only for volumes attached to that specific instance (flag delete-on-termination is True)
                        volumeFlag=1 ;;
                h) # display Help
                        Help
                exit;;
        esac
done

if [ -z "$nameTag" ];
then
        echo -n "Please enter target EC2 instance Name tag value: "
        read nameTag
fi

if [ -z "$requestedIncrement" ];
then
        echo -n "Please enter value by which you want to increment target instance volumes space: "
        read requestedIncrement
fi

instanceId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${nameTag}" --output text --query 'Reservations[*].Instances[*].InstanceId')


if [[ $volumeFlag -eq 1 ]]
then
        aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=${instanceId} Name=attachment.delete-on-termination,Values=true --query 'Volumes[*].VolumeId'
else
        aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=${instanceId}" --query 'Volumes[*].VolumeId'
fi |
jq -r '.[]' |
while read i; do
        originalSize=$(aws ec2 describe-volumes --output text --volume-ids $i --query 'Volumes[*].Size')
        newSize=$(($originalSize+$requestedIncrement))
        aws ec2 modify-volume --size $newSize --volume-id $i
done

echo
echo "Don't forget to reallocate volumes from the inside of target machines."