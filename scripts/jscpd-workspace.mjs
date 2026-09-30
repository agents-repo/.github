#!/usr/bin/env node
import { runJscpd } from './jscpd-run.mjs';

runJscpd(['.', '../cli', '../webapp', '../registry', '../registry-proxy']);
