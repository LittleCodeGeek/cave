#!/bin/bash
iptables -t nat -I PREROUTING -p tcp --dport $1 -j REDIRECT --to-port $2

