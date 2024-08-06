alter table "public"."users" drop column "name";

alter table "public"."users" add column "first_name" character varying(255) not null;

alter table "public"."users" add column "last_name" character varying(255) not null;


