#ifndef TCP_CLIENT_H_
#define TCP_CLIENT_H_

#include "lwip/tcp.h"
#include "memp.h"
#include "lwip/debug.h"
#include "lwip/stats.h"
#include <stdio.h>
#include <string.h>

void tcp_setup(void);
uint32_t tcp_send_packet(void);
err_t tcpErrorHandler(void);
err_t tcpSendCallback(void);
err_t connectCallback(void *arg, struct tcp_pcb *tpcb, err_t err);
err_t tcpRecvCallback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);

#endif
