#include "tcp_client.h"

struct tcp_pcb *testpcb;
err_t error;

void tcp_setup(void)
{
    uint32_t data = 0xdeadbeef;

    /* create an ip */
    struct ip_addr ip;
    IP4_ADDR(&ip, 110,777,888,999);    //IP of my PHP server

    /* create the control block */
    testpcb = tcp_new();    //testpcb is a global struct tcp_pcb
                            // as defined by lwIP



    tcp_arg(testpcb, &data);
    /* dummy data to pass to callbacks*/

    /* register callbacks with the pcb */

    tcp_err(testpcb, tcpErrorHandler);
    tcp_recv(testpcb, tcpRecvCallback);
    tcp_sent(testpcb, tcpSendCallback);

    /* now connect */
    tcp_connect(testpcb, &ip, 80, connectCallback);
}

/* connection established callback, err is unused and only return 0 */
err_t connectCallback(void *arg, struct tcp_pcb *tpcb, err_t err)
{
    printf("Connection Established.\n\r");
    printf("Now sending a packet\n\r");
    tcp_send_packet();
    return 0;
}

uint32_t tcp_send_packet(void)
{
    char *string = "HEAD /process.php?data1=12&data2=5 HTTP/1.0\r\nHost: mywebsite.com\r\n\r\n ";
    uint32_t len = strlen(string);

    /* push to buffer */
        error = tcp_write(testpcb, string, strlen(string), TCP_WRITE_FLAG_COPY);

    if (error) {
        printf("ERROR: Code: %d (tcp_send_packet :: tcp_write)\n", error);
        return 1;
    }

    /* now send */
    error = tcp_output(testpcb);
    if (error) {
        printf("ERROR: Code: %d (tcp_send_packet :: tcp_output)\n", error);
        return 1;
    }
    return 0;
}

err_t tcpRecvCallback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err)
{
    printf("Data recieved.\n");
    if (p == NULL) {
        printf("The remote host closed the connection.\n");
        printf("Now I'm closing the connection.\n");
        tcp_close_con();
        return ERR_ABRT;
    } else {
        printf("Number of pbufs %d\n", pbuf_clen(p));
        printf("Contents of pbuf %s\n", (char *)p->payload);
    }
    return 0;
}
