# Firewalld Troubleshooting Guide

## Overview
This guide provides a step-by-step process for troubleshooting and resolving common issues with `firewalld` on Linux systems, particularly when you encounter connectivity issues like "No route to host". In our case, reinstalling `firewalld` resolved the issue.

## Table of Contents
1. [Introduction](#introduction)
2. [Verifying Active Zones](#verifying-active-zones)
3. [Binding Network Interfaces to a Zone](#binding-network-interfaces-to-a-zone)
4. [Backing Up Firewalld Configuration](#backing-up-firewalld-configuration)
5. [Reinstalling Firewalld](#reinstalling-firewalld)
6. [Post-Reinstallation Verification](#post-reinstallation-verification)
7. [Troubleshooting Tips](#troubleshooting-tips)
8. [Conclusion](#conclusion)

## Introduction
When connectivity issues occur (e.g., "No route to host"), it could be due to misconfigurations in `firewalld`. This guide outlines how to check your configuration, back up current settings, reinstall `firewalld`, and verify that everything is working as expected.

## Verifying Active Zones
Check if any active zones are configured:
```bash
sudo firewall-cmd --get-active-zones
