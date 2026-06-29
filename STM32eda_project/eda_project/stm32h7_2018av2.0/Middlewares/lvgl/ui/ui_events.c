////
//// Created by 24016 on 2023/7/31.
////
//#include "ui_events.h"
//
//
//uint8_t scan_flag=0;
//
//void scan_button_eb(lv_event_t * e){
//    lv_event_code_t code= lv_event_get_code(e);
//    if(code==LV_EVENT_CLICKED){
//        if(scan_flag==0)
//            scan_flag=1;//置位，在扫频完毕后记得恢复
//        else
//            printf("\n\rSCAN HAS LAUCHED!\n\r");
//    }
//}
//
//void Smith_Chart_eb(lv_event_t * e){
//    static int32_t last_id = -1;
//    lv_event_code_t code = lv_event_get_code(e);
//    lv_obj_t * obj = lv_event_get_target(e);
//
//    if(code == LV_EVENT_PRESSED||code==LV_EVENT_PRESSING) {
//        last_id = lv_chart_get_pressed_point(obj);
//        if(last_id != LV_CHART_POINT_NONE) {
//            lv_chart_set_cursor_point(obj, smith_cursor, NULL, last_id);
//        }
//    }
//    else if(code == LV_EVENT_DRAW_PART_END) {
//        lv_obj_draw_part_dsc_t * dsc = lv_event_get_draw_part_dsc(e);
//        if(dsc->part == LV_PART_CURSOR && dsc->p1 && dsc->p2 && dsc->p1->y == dsc->p2->y && last_id >= 0) {
////            lv_coord_t * data_array = lv_chart_get_y_array(ui_Chart2, smith_wave);
////            lv_coord_t v = data_array[last_id];
////            char buf[16];
////            lv_snprintf(buf, sizeof(buf), "%d", v);
////
////            lv_point_t size;
////            lv_txt_get_size(&size, buf, LV_FONT_DEFAULT, 0, 0, LV_COORD_MAX, LV_TEXT_FLAG_NONE);
////
////            lv_area_t a;
////            a.y2 = dsc->p1->y - 5;
////            a.y1 = a.y2 - size.y - 10;
////            a.x1 = dsc->p1->x + 10;
////            a.x2 = a.x1 + size.x + 10;
////
////            lv_draw_rect_dsc_t draw_rect_dsc;
////            lv_draw_rect_dsc_init(&draw_rect_dsc);
////            draw_rect_dsc.bg_color = lv_palette_main(LV_PALETTE_BLUE);
////            draw_rect_dsc.radius = 3;
////
////            lv_draw_rect(&a, dsc->clip_area, &draw_rect_dsc);
////
////            lv_draw_label_dsc_t draw_label_dsc;
////            lv_draw_label_dsc_init(&draw_label_dsc);
////            draw_label_dsc.color = lv_color_white();
////            a.x1 += 5;
////            a.x2 -= 5;
////            a.y1 += 5;
////            a.y2 -= 5;
////            lv_draw_label(&a, dsc->clip_area, &draw_label_dsc, buf, NULL);
//        }
//    }
//
//}
//void chart_draw_event_cb(lv_event_t* e){
//    lv_obj_draw_part_dsc_t* dsc = lv_event_get_draw_part_dsc(e);
//    if (!lv_obj_draw_part_check_type(dsc, &lv_chart_class, LV_CHART_DRAW_PART_TICK_LABEL))
//        return;
//    if (dsc->text)
//    {
//        if (dsc->id == LV_CHART_AXIS_PRIMARY_X)
//        {
//            const char* level[] = { "L1", "L2", "L3", "L4"};
//            lv_snprintf(dsc->text, dsc->text_length, "%s", level[dsc->value / 100]);
//        }
//        if (dsc->id == LV_CHART_AXIS_PRIMARY_Y)
//        {
//            const char* level[] = { "L1", "L2", "L3", "L4"};
//            lv_snprintf(dsc->text, dsc->text_length, "%s", level[dsc->value / 100]);
//        }
//    }
//
//}