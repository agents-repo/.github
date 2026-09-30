#!/usr/bin/env node
import { runJscpd } from './jscpd-run.mjs';

runJscpd([
  '.',
  '../cli',
  '../webapp',
  '../registry',
  '../registry-proxy',
  '../../feline-click/.github',
  '../../feline-click/api',
  '../../feline-click/webapp',
]);
