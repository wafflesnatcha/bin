# getvars
# List all variables (even those not exported)
getvars() { set | grep -E '^[a-zA-Z0-9_]+='; }
export -f getvars