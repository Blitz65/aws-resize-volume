Script increments volumes of instance specified by it's Name tag value. Particular incrementation size is specified by user as well

Depending on flags, script can either resize only instance volume marked as Delete On Termination by default in AWS, or all volumes related to the specified by Name tag instance.
In current state, script requires to be launched from session with pre-configured aws connection.

## Usage:

Launch script either with passing parameters via -n and -i flags or just by directly calling it with no inputs.
If no information on Tag Name and Volume Size Increment values wasn't provided, user will get prompts to specify them since they are mandatory for launch.

List of available as of now flags:
  - -n: value of target instance's Name tag.
  - -i: by how many GB will all the volumes received by the script will be inscreased.
  - -a: increment size only for the volumes tied to specified instance. Befault Root foldier, for example, is marked as Delete On Termination, meaning that on termination of the instance it's connected to, it will be deleted as well.
  - -h: print Help.

By default, script resizes by provided value all volumes connected to the instance. To target only volumes that are marked as Delete On Termination, -a flag needs to be provided.
