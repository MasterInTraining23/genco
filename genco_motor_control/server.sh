#!/bin/bash

source /home/genco/workspace/genco_motor_control/.venv/bin/activate

/home/genco/workspace/genco_motor_control/.venv/bin/python /home/genco/workspace/genco_motor_control/motor-control-service.py pwm 

deactivate
